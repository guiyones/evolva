require "test_helper"

class ChallengeParticipantTest < ActiveSupport::TestCase
  test ".active returns only active participants" do
    assert_includes ChallengeParticipant.active, challenge_participants(:one_active)
  end

  test "rejects invalid status" do
    assert_raises(ArgumentError) do
      ChallengeParticipant.new(status: "bogus")
    end
  end
end
