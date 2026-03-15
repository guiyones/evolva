class HistoryController < ApplicationController
  def index
    @completed_challenges = Current.user.challenges
                                          .where(status: "completed", quest_id: nil)
                                          .order(completed_at: :desc)

    @finished_challenges = Current.user.challenges
                                        .where(status: "finished", quest_id: nil)
                                        .order(completed_at: :desc)

    @completed_quests = Current.user.quests
                                      .where(status: "completed")
                                      .order(completed_at: :desc)

    @redeemed_rewards = Current.user.rewards
                                    .where(status: "redeemed")
                                    .includes(:challenge, :quest)
                                    .order(completed_at: :desc)
  end
end
