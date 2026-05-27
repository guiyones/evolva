class ChallengesController < ApplicationController
  before_action :set_challenge, only: [ :show, :edit, :update, :destroy, :restart ]

  def index
    @challenges = Current.user.challenges.independent.recent
  end

  def show
    @challenge.check_status!
  end

  def new
    @challenge = Challenge.new
    @challenge.quest_id = params[:quest_id] if params[:quest_id]
    @challenge.challenge_type = params[:type] || "solo"
    @challenge.build_reward
    @active_quests = Current.user.quests.active.recent
  end

  def create
    @challenge = Current.user.challenges.build(challenge_params)
    @challenge.challenge_type ||= "solo"
    @challenge.reward.user = Current.user if @challenge.reward.present?

    if @challenge.save
      redirect_to @challenge, notice: "Desafio criado!"
    else
      @active_quests = Current.user.quests.active.recent
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @challenge.update(edit_params)
      redirect_to @challenge, notice: "Desafio atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @challenge.destroy
    redirect_to challenges_path, notice: "Desafio removido"
  end

  def restart
    redirect_to @challenge.restart!, notice: "Desafio recomeçado!"
  end

  private

  def set_challenge
    @challenge = Current.user.challenges.find(params[:id])
  end

  def challenge_params
    params.require(:challenge).permit(
      :title, :description, :duration_days, :quest_id, :challenge_type,
      tag_ids: [],
      reward_attributes: [ :description ]
    )
  end

  def edit_params
    params.require(:challenge).permit(:title, :description)
  end
end
