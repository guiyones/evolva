require "test_helper"

class QuestTest < ActiveSupport::TestCase
  test ".active returns only active quests" do
    assert_includes Quest.active, quests(:leitura)
    assert_not_includes Quest.active, quests(:completada)
  end

  test ".completed returns only completed quests" do
    assert_includes Quest.completed, quests(:completada)
    assert_not_includes Quest.completed, quests(:leitura)
  end

  test "rejects invalid status" do
    assert_raises(ArgumentError) do
      Quest.new(status: "bogus")
    end
  end

  test "#current_challenge returns focused_challenge when present" do
    quest = quests(:leitura)
    challenge = quest.challenges.create!(title: "Ler", duration_days: 10, status: :active, started_at: 1.day.ago, user: quest.user)
    challenge.checkins.create!(day_number: 1, feeling: "ok")
    assert_equal challenge, quest.current_challenge
  end

  test "#current_challenge falls back to first planned challenge when no focused" do
    quest = quests(:leitura)
    assert_equal challenges(:planned_in_quest), quest.current_challenge
  end
end
