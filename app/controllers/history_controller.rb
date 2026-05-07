class HistoryController < ApplicationController
  def index
    @completed_challenges = Current.user.challenges
                                          .where(status: "completed")
                                          .includes(:quest)
                                          .order(completed_at: :desc)

    @finished_challenges = Current.user.challenges
                                        .where(status: "finished")
                                        .includes(:quest, :restarts)
                                        .order(completed_at: :desc)

    @completed_quests = Current.user.quests
                                      .where(status: "completed")
                                      .order(completed_at: :desc)
  end
end
