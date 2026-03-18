class CheckinsController < ApplicationController
  before_action :set_challenge

  def new
    @checkin = Checkin.new
  end

  def create
    if already_checked_in_today?
      redirect_to @challenge, alert: "Você já fez check-in hoje."
      return
    end

    @checkin = @challenge.checkins.build(checkin_params)
    @checkin.day_number = @challenge.progress + 1

    if @checkin.save
      @challenge.check_status!
      redirect_to @challenge, notice: checkin_message
    else 
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    @checkin = @challenge.checkins.find(params[:id])
  end


  private

  def already_checked_in_today?
    @challenge.checkins.where(created_at: Date.current.all_day).exists?
  end
   
  def set_challenge
    @challenge = Current.user.challenges.find(params[:challenge_id])
  end

  def checkin_params
    params.require(:checkin).permit(:feeling, :note)
  end

  def checkin_message
    if @challenge.completed?
      "#{@challenge.duration_days} de #{@challenge.duration_days} dias. Você fez examentamente o que prometeu. 🎉"
    else 
      "Dia #{@checkin.day_number} registrado"
    end
  end
end
