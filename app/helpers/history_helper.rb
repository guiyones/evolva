module HistoryHelper
  def quest_label(challenge)
    return unless challenge.quest.present?
    "↑ Jornada: #{challenge.quest.title}"
  end

  def restart_label(challenge)
    return unless challenge.restarted?
    count = challenge.restarts.count
    count > 1 ? "↻ recomeçado #{count} vezes" : "↻ recomeçado uma vez"
  end
end
