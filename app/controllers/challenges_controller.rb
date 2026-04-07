class ChallengesController < ApplicationController
  before_action :set_challenge, only: [:show, :edit, :update, :destroy]

  def index
    @challenges = Current.user.challenges.order(created_at: :desc)
  end

  def show
    @challenge.check_status!
  end

  def new
    @challenge = Challenge.new
    @challenge.challenge_type == params[:type] || "solo"
    @challenge.build_reward
  end

  def create
    @challenge = Current.user.challenges.build(challenge_params)
    @challenge.challenge_type ||= "solo"
    @challenge.reward.user = Current.user if @challenge.reward.present?
    
    if @challenge.save
      if @challenge.shared?
        @challenge.challenge_participants.create!(
          user: Current.user,
          status: "active"
        )
      end
      redirect_to @challenge, notice: "Desafio criado!"
    else 
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

  private 

  def set_challenge
    @challenge = Current.user.challenges.find(params[:id])
  end

  def challenge_params
    params.require(:challenge).permit(:title, :description, :duration_days, :quest_id, :challenge_type, reward_attributes: [:description])
  end

  def edit_params
    params.require(:challenge).permit(:title, :description)
  end
end
