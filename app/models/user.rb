class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :challenges, dependent: :destroy
  has_many :rewards, dependent: :destroy
  has_many :quests, dependent: :destroy
  has_many :challenge_participants, dependent: :destroy
  has_many :shared_challenges, through: :challenge_participants, source: :challenge
  belongs_to :focused_quest, class_name: "Quest", optional: true

  validate :focused_quest_owned_by_user_and_active

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def display_name
    name.presence || email_address.split("@").first.titleize
  end

  def initials
    (name.presence&.first || email_address.first).upcase
  end

  private

  def focused_quest_owned_by_user_and_active
    return if focused_quest.blank?

    if focused_quest.user_id != id
      errors.add(:focused_quest, "deve pertencer a você")
    elsif !focused_quest.active?
      errors.add(:focused_quest, "precisa estar ativa")
    end
  end
end
