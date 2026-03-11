class ChallengesController < ApplicationController
  before_action :set_challenge, only: [:show]

  def index
    @challenges = Current.user.challenges.order(created_at: :desc)
  end

  def show
    @challenge.check_status!
  end

  def new
    @challenge = Challenge.new
  end

  def create
    @challenge = Current.user.challenges.build(challenge_params)

    if @challenge.save
      redirect_to @challenge, notice: "Desafio criado!"
    else 
      render :new, status: :unprocessable_entity
    end
  end

  private 

  def set_challenge
    @challenge = Current.user.challenges.find(params[:id])
  end

  def challenge_params
    params.require(:challenge).permit(:title, :description, :duration_days)
  end
end
