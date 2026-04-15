class QuestsController < ApplicationController
  before_action :set_quest, only: [ :show, :edit, :update, :destroy ]

  def index
    @quests = Current.user.quests.order(created_at: :desc)
  end

  def show
    @quest.check_status!
  end

  def new
    @quest = Quest.new
    @quest.build_reward
  end

  def create
    @quest = Current.user.quests.build(quest_params)
    @quest.reward.user = Current.user if @quest.reward.present?

    if @quest.save
      redirect_to @quest, notice: "Quest criada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @quest.update(edit_params)
      redirect_to @quest, notice: "Quest atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quest.destroy
    redirect_to quests_path, notice: "Quest removida."
  end

  def attach_challenge
    @quest = Current.user.quests.find(params[:id])
    @challenge = Current.user.challenges.find(params[:challenge_id])

    if @challenge.update(quest_id: @quest.id, status: "planned")
      redirect_to @quest, notice: "Desafio adicionada a jornada"
    else
      redirect_to @quest, alert: "Não foi possivel adicionar o desafio"
    end
  end

  private

  def set_quest
    @quest = Current.user.quests.find(params[:id])
  end

  def quest_params
    params.require(:quest).permit(:title, :description, reward_attribuites: [ :description ])
  end

  def edit_params
    params.require(:quest).permit(:title, :description)
  end
end
