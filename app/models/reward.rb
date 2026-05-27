class Reward < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  belongs_to :quest, optional: true

  enum :status, { locked: "locked", unlocked: "unlocked", redeemed: "redeemed" }

  validates :description, presence: true

  before_validation :set_defaults, on: :create

  def redeem!
    update!(status: :redeemed, completed_at: Time.current)
  end

  private

  def set_defaults
    self.status ||= "locked"
  end
end
