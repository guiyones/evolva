class HomeController < ApplicationController
  def index
    @active_challenges = Current.user.challenges.active.independent.recent

    @active_quests = Current.user.quests.active.includes(:challenges, :reward).recent

    @unlocked_rewards = Current.user.rewards.unlocked.includes(:challenge, :quest)
    @locked_rewards = Current.user.rewards.locked.includes(:challenge, :quest)

    @streak = Current.user.current_streak

    @active_count = Current.user.active_challenges_count
    @solo_count = Current.user.challenges.active.independent.where(challenge_type: [ "solo", nil ]).count
    @shared_count = Current.user.challenges.active.where(challenge_type: "shared").count

    @unlocked_count = Current.user.unlocked_rewards_count

    @today_challenges = Current.user.challenges.active.order(created_at: :asc)

    @today_checkins = Checkin.where(
      challenge_id: @today_challenges.map(&:id),
      created_at: Date.current.all_day
    ).pluck(:challenge_id).to_set

    total = @today_challenges.count
    done = @today_checkins.count
    @day_progress = total > 0 ? [ (done.to_f / total * 100).round, 100 ].min : 0
  end
end

