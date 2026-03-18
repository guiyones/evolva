class Checkin < ApplicationRecord
  belongs_to :challenge

  validates :day_number, presence: true, uniqueness: { scope: :challenge_id }
  normalizes :feeling, with: ->(v) { v.presence }

  validates :feeling, inclusion: { in: %w[hard ok easy] }, allow_nil: true

  scope :ordered, -> { order(day_number: :asc) }
end
