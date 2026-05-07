class Quest < ApplicationRecord
  belongs_to :user

  has_many :challenges, dependent: :destroy
  has_one :reward, dependent: :destroy
  accepts_nested_attributes_for :reward, reject_if: :all_blank

  validates :title, presence: true 
  validates :status, inclusion: { in: %w[active completed] }

  before_validation :set_defaults, on: :create

  def progress 
    challenges.where(status: "completed").count
  end

  def total
    challenges.count
  end

  def progress_percentage
    return 0 if total.zero?
    [(progress.to_f / total * 100).round, 100].min
  end

  def active?
    status == "active"
  end

  def completed?
    status == "completed"
  end

  def active_challenges
    challenges.where(status: "active").order(created_at: :asc)
  end

  def focused_challenge
    challenges.joins(:checkins).order("checkins.created_at DESC").first
  end

  def can_add_challenge?
    !completed?
  end

  def check_status!
    return if completed?
    if total > 0 && progress == total 
      update!(status: "completed", completed_at: Time.current)
      reward&.unlock!
    end
  end

  private

  def set_defaults
    self.status ||= "active"
    self.started_at ||= Time.current
  end
end
