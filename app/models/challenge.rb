class Challenge < ApplicationRecord
  belongs_to :user
  belongs_to :quest, optional: true
  belongs_to :parent_challenge, class_name: "Challenge", optional: true

  has_many :checkins, dependent: :destroy
  has_many :challenge_participants, dependent: :destroy
  has_many :participants, through: :challenge_participants, source: :user
  has_many :child_challenges, class_name: "Challenge", foreign_key: :parent_challenge_id
  has_one :reward, dependent: :destroy

  accepts_nested_attributes_for :reward, reject_if: :all_blank

  validates :title, presence: true
  validates :duration_days, presence: true, numericality: { greater_than: 0}
  validates :status, inclusion: { in: %w[active completed finished] }

  before_validation :set_defaults, on: :create
  before_create :generate_invite_token

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
    challenges = [root_challenge] + root_challenge.child_challenges
    challenges.all?(&:completed?)
  end

  def progress
    checkins.count
  end

  def progress_percentage
    return 0 if duration_days.zero?
    [(progress.to_f / duration_days * 100).round, 100].min 
  end

  def completed?
    status == "completed"
  end

  def finished?
    status == "finished"
  end

  def active?
    status == "active"
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
      update!(status: "completed", completed_at: Time.current)
      if solo?
        reward&.unlock!
      else 
        root_challenge.reward&.unlock! if root_challenge.all_participants_completed?
      end
    elsif expired? && progress < duration_days
      update!(status: "finished", completed_at: Time.current)
    end
  end

  def checked_days
    checkins.pluck(:day_number).to_set
  end

  def complete!
    update!(status: "completed", completed_at: Time.current)
  end

  private 

  def set_defaults
    self.status ||= "active"
  end

  def generate_invite_token
    self.invite_token ||= SecureRandom.urlsafe_base64(8)
  end

end
