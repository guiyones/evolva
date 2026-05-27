class ChallengeParticipantsController < ApplicationController
  def create
    original = Challenge.find_by!(invite_token: params[:token])

    if original.participants.include?(Current.user)
      redirect_to original, alert: "Você já está participando deste desafio."
    else
      redirect_to original.share_with(Current.user), notice: "Você entrou no desafio! Bora lá 🔥"
    end
  end

  def destroy
    participant = Current.user.challenge_participants.find(params[:id])
    participant.destroy
    redirect_to root_path, notice: "Você saiu do desafio."
  end
end
