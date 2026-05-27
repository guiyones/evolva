class HomeController < ApplicationController
  def index
    @active_challenges = Current.user.challenges.active.independent.recent
    @active_quests = Current.user.quests.active.includes(:challenges, :reward).recent

    @unlocked_rewards = Current.user.rewards.unlocked.includes(:challenge, :quest)
    @locked_rewards = Current.user.rewards.locked.includes(:challenge, :quest)
    @rewards = @unlocked_rewards.to_a + @locked_rewards.to_a

    @streak = Current.user.current_streak
    @active_count = Current.user.active_challenges_count
    @solo_count = Current.user.challenges.active.independent.where(challenge_type: [ "solo", nil ]).count
    @shared_count = Current.user.challenges.active.where(challenge_type: "shared").count
    @unlocked_count = Current.user.unlocked_rewards_count

    today_challenges = Current.user.challenges.active.order(created_at: :asc).to_a
    @today_checkins = Checkin.where(
      challenge_id: today_challenges.map(&:id),
      created_at: Date.current.all_day
    ).pluck(:challenge_id).to_set

    @today_pending, @today_done = today_challenges.partition { |c| !@today_checkins.include?(c.id) }
    @today_challenges = @today_pending + @today_done
    @day_progress = day_progress(today_challenges, @today_done)
  end

  private
    def day_progress(challenges, done)
      return 0 if challenges.empty?
      [ (done.size.to_f / challenges.size * 100).round, 100 ].min
    end
end
