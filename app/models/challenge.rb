class Challenge < ApplicationRecord
  belongs_to :user
  belongs_to :quest, optional: true
  belongs_to :parent_challenge, class_name: "Challenge", optional: true
  belongs_to :restarted_from, class_name: "Challenge", optional: true

  has_many :checkins, dependent: :destroy
  has_many :challenge_participants, dependent: :destroy
  has_many :participants, through: :challenge_participants, source: :user
  has_many :child_challenges, class_name: "Challenge", foreign_key: :parent_challenge_id
  has_many :restarts, class_name: "Challenge", foreign_key: :restarted_from_id, dependent: :nullify
  has_many :challenge_tags, dependent: :destroy
  has_many :tags, through: :challenge_tags
  has_one :reward, dependent: :destroy

  accepts_nested_attributes_for :reward, reject_if: :all_blank

  enum :status, { planned: "planned", active: "active", completed: "completed", finished: "finished" }

  scope :independent, -> { where(quest_id: nil) }
  scope :recent, -> { order(created_at: :desc) }

  validates :title, presence: true
  validates :duration_days, presence: true, numericality: { greater_than: 0 }

  before_validation :set_defaults, on: :create
  before_create :generate_invite_token
  after_create :add_owner_as_participant, if: :shared?

  def root_challenge
    parent_challenge || self
  end

  def shared?
    challenge_type == "shared"
  end

  def solo?
    challenge_type == "solo"
  end

  def all_participants_completed?
    return completed? if solo?
    challenges = [ root_challenge ] + root_challenge.child_challenges
    challenges.all?(&:completed?)
  end

  def progress
    checkins.count
  end

  def progress_percentage
    return 0 if duration_days.zero?
    [ (progress.to_f / duration_days * 100).round, 100 ].min
  end

  def focused_today?
    checkins.where(created_at: Date.current.all_day).exists?
  end

  def focused?
    return false unless quest_id.present?
    quest.focused_challenge&.id == id
  end

  def current_day
    return 1 unless started_at.present?
    (Date.current - started_at.to_date).to_i + 1
  end

  def end_date
    return nil unless started_at.present?
    started_at.to_date + duration_days
  end

  def expired?
    return false unless end_date.present?
    Date.current >= end_date
  end

  def check_status!
    return if completed?
    return unless started_at.present?
    return if checkins.empty?

    if progress >= duration_days
      update!(status: :completed, completed_at: Time.current)
      reward&.unlocked!
      if shared?
        root_challenge.reward&.unlocked! if root_challenge.all_participants_completed?
      end
      quest&.check_status!
    elsif expired? && progress < duration_days
      update!(status: :finished, completed_at: Time.current)
    end
  end

  def checked_days
    checkins.pluck(:day_number).to_set
  end

  def complete!
    update!(status: :completed, completed_at: Time.current)
  end

  def share_with(user)
    copy = user.challenges.create!(
      title: title,
      description: description,
      duration_days: duration_days,
      challenge_type: "shared",
      parent_challenge_id: id,
      status: :active,
      started_at: Time.current
    )
    update!(challenge_type: "shared") if solo?
    challenge_participants.create!(user: user, status: :active)
    copy
  end

  def start!
    return if active? && started_at.present?

    if planned?
      update!(status: :active, started_at: Time.current)
    else
      update!(started_at: Time.current)
    end
  end

  def restart!
    user.challenges.create!(
      title: title,
      description: description,
      duration_days: duration_days,
      quest_id: quest_id,
      challenge_type: challenge_type,
      restarted_from_id: id,
      status: :active,
      started_at: Time.current,
      tag_ids: tag_ids
    )
  end

  def restarted?
    restarts.exists?
  end

  private

  def set_defaults
    self.status ||= quest_id.present? ? "planned" : "active"
  end

  def generate_invite_token
    self.invite_token ||= SecureRandom.urlsafe_base64(8)
  end

  def add_owner_as_participant
    challenge_participants.create!(user: user, status: :active)
  end
end
