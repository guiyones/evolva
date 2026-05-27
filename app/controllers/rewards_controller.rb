class RewardsController < ApplicationController
  before_action :set_reward

  def show
  end

  def redeem
    if @reward.unlocked?
      @reward.redeem!
      redirect_to @reward, notice: "Reward resgatado! Você merece. 🎉"
    else
      redirect_to @reward, alert: "Reward ainda não disponível"
    end
  end

  private

  def set_reward
    @reward = Current.user.rewards.find(params[:id])
  end
end
