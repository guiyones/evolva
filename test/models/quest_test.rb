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
end
