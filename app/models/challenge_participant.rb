class ChallengeParticipant < ApplicationRecord
  belongs_to :challenge
  belongs_to :user

  enum :status, { pending: "pending", active: "active", completed: "completed" }

  validates :user_id, uniqueness: { scope: :challenge_id }

  before_validation :set_defaults, on: :create

  private

  def set_defaults
    self.status ||= "active"
  end
end
