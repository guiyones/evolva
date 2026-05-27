class ChallengeTag < ApplicationRecord
  belongs_to :challenge
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :challenge_id }
end
