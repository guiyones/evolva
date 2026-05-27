module ChallengesHelper
  def challenge_status_text(challenge)
    if challenge.completed?
      [ "✓ Concluído", "list-card-status-success" ]
    elsif challenge.finished? || challenge.planned?
      [ challenge.finished? ? "Encerrado" : "Planejado", "list-card-status-muted" ]
    elsif challenge.focused?
      [ "🔵 Foco", "list-card-status-active" ]
    else
      [ "Em andamento", "list-card-status-active" ]
    end
  end

  def challenge_status_badge(challenge)
    label, modifier =
      if challenge.completed?
        [ "✓ Concluído", "completed" ]
      elsif challenge.finished?
        [ "Encerrado", "finished" ]
      elsif challenge.planned?
        [ "Planejado", "planned" ]
      elsif challenge.focused?
        [ "🔵 Foco", "focused" ]
      else
        [ challenge.shared? ? "Compartilhado" : "Em andamento", "active" ]
      end

    tag.span label, class: "challenge-status challenge-status-#{modifier}"
  end
end
