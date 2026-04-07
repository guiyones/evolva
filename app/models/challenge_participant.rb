class ChallengeParticipant < ApplicationRecord
  belongs_to :challenge
  belongs_to :user

  validates :status, inclusion: { in: %w[pending active completed]}
  validates :user_id, uniqueness: { scope: :challenge_id }

  before_validation :set_defaults, on: :create

  def active?
    status == "active"
  end

  def completed?
    status == "completed"
  end

  private

  def set_defaults
    self.status ||= "active"
  end
end
