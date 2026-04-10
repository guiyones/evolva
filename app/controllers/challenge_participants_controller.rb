class ChallengeParticipantsController < ApplicationController
  
  def create
    @original = Challenge.find_by!(invite_token: params[:token])

    if @original.participants.include?(Current.user)
      redirect_to @original, alert: "Você já está participando deste desafio."
      return
    end

    # Cria cópia do challenge para o convidado
    @copy = Current.user.challenges.create!(
      title: @original.title,
      description: @original.description,
      duration_days: @original.duration_days,
      challenge_type: "shared",
      parent_challenge_id: @original.id,
      status: "active",
      started_at: Time.current
    )

    # Marca o original como compartilhado se ainda for solo
    @original.update!(challenge_type: "shared") if @original.solo?

    # Vincula o convidado como participante do desafio original
    @original.challenge_participants.create!(
      user: Current.user,
      status: "active"
    )

    redirect_to @copy, notice: "Você entrou no desafio! Bora lá 🔥"
  end


  def destroy
    participant = Current.user.challenge_participants.find(params[:id])
    participant.destroy
    redirect_to root_path, notice: "Você saiu do desafio."
  end
end
