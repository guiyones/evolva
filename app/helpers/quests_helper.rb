module QuestsHelper
  def quest_status_badge(quest)
    if quest.completed?
      tag.span "✓ Concluída", class: "quest-status quest-status-completed"
    else
      tag.span "Em andamento", class: "quest-status quest-status-active"
    end
  end

  def quest_challenge_state(challenge)
    return "completed" if challenge.completed?
    return "active" if challenge.active?
    return "finished" if challenge.finished?
    "planned"
  end
end
