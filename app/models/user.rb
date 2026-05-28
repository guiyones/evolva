class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :challenges, dependent: :destroy
  has_many :rewards, dependent: :destroy
  has_many :quests, dependent: :destroy
  has_many :challenge_participants, dependent: :destroy
  has_many :shared_challenges, through: :challenge_participants, source: :challenge
  belongs_to :focused_quest, class_name: "Quest", optional: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def display_name
    name.presence || email_address.split("@").first.titleize
  end

  def initials
    (name.presence&.first || email_address.first).upcase
  end

  def current_streak
    streak = 0
    date = Date.current

    loop do
      has_checkin = challenges.joins(:checkins)
        .where(checkins: { created_at: date.all_day })
        .exists?
      break unless has_checkin
      streak += 1
      date -= 1.day
    end

    streak
  end

  def active_challenges_count
    challenges.active.count
  end

  def unlocked_rewards_count
    rewards.unlocked.count
  end
end
