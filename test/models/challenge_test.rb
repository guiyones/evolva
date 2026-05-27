require "test_helper"

class ChallengeTest < ActiveSupport::TestCase
  test ".active returns only active challenges" do
    assert_includes Challenge.active, challenges(:active_solo)
    assert_not_includes Challenge.active, challenges(:completed_solo)
    assert_not_includes Challenge.active, challenges(:planned_in_quest)
    assert_not_includes Challenge.active, challenges(:finished_solo)
  end

  test ".planned returns only planned challenges" do
    assert_includes Challenge.planned, challenges(:planned_in_quest)
    assert_not_includes Challenge.planned, challenges(:active_solo)
  end

  test ".completed returns only completed challenges" do
    assert_includes Challenge.completed, challenges(:completed_solo)
    assert_not_includes Challenge.completed, challenges(:active_solo)
  end

  test ".finished returns only finished challenges" do
    assert_includes Challenge.finished, challenges(:finished_solo)
    assert_not_includes Challenge.finished, challenges(:active_solo)
  end

  test ".independent returns challenges without a quest" do
    assert_includes Challenge.independent, challenges(:active_solo)
    assert_not_includes Challenge.independent, challenges(:planned_in_quest)
  end

  test "rejects invalid status" do
    assert_raises(ArgumentError) do
      Challenge.new(status: "bogus")
    end
  end
end
