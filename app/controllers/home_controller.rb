class HomeController < ApplicationController
  def index
    @active_challenges = Current.user.challenges
                                     .where(status: "active", quest_id: nil)
                                     .order(created_at: :desc)
    @active_quests = Current.user.quests
                                  .where(status: "active")
                                  .includes(:challenges, :reward)
                                  .order(created_at: :desc)
    @unlocked_rewards = Current.user.rewards
                                    .where(status: "unlocked")
                                    .includes(:challenge, :quest)
    @locked_rewards = Current.user.rewards
                                   .where(status: "locked")
                                   .includes(:challenge, :quest)
    @streak = Current.user.current_streak
    @active_count = Current.user.active_challenges_count
    @unlocked_count = Current.user.unlocked_rewards_count

    @today_challenges = Current.user.challenges
                                    .where(status: "active")
                                    .order(created_at: :asc)
    @today_checkins = Checkin.where(
      challenge_id: @today_challenges.map(&:id),
      created_at: Date.today.all_day
    ).pluck(:challenge_id).to_set

    total = @today_challenges.count
    done = @today_checkins.count
    @day_progress = total > 0 ? [(done.to_f / total * 100).round, 100].min : 0
  end
end

