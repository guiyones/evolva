class NormalizeQuestChallengeStatus < ActiveRecord::Migration[8.0]
  def up
    Challenge.where(status: "paused").find_each do |challenge|
      challenge.started_at ||= Time.current
      challenge.status = "active"
      challenge.save!(validate: false)
    end
  end

  def down
  end
end
