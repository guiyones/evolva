class Challenge < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :duration_days, presence: true, numericality: { greater_than: 0}
  validates :status, inclusion: { in: %w[active completed finished] }

  before_validation :set_defaults, on: :create

  def progress
    checkins.count
  end

  def progress_porcentage
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

  def end_date
    started_at + duration_days.days 
  end

  def expired?
    Time.current > end_date
  end

  def check_status!
    return if completed?

    if progress >= duration_days
      update!(status:"completed", completed_at: Time.current)
    elsif
      update!(status: "finished", completed_at: Time.current)
    end
  end

  def complete!
    update!(status: "completed", completed_at: Time.current)
  end

  private 

  def set_defaults
    self.status ||= "active"
    self.started_at ||= Time.current
  end
end
