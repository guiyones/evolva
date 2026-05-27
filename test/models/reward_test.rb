require "test_helper"

class RewardTest < ActiveSupport::TestCase
  test ".locked, .unlocked, .redeemed return correct subsets" do
    assert_includes Reward.locked, rewards(:locked_one)
    assert_not_includes Reward.locked, rewards(:unlocked_one)

    assert_includes Reward.unlocked, rewards(:unlocked_one)
    assert_not_includes Reward.unlocked, rewards(:locked_one)

    assert_includes Reward.redeemed, rewards(:redeemed_one)
    assert_not_includes Reward.redeemed, rewards(:locked_one)
  end

  test "redeem! marks redeemed and sets completed_at" do
    reward = rewards(:unlocked_one)
    freeze_time = Time.current
    travel_to(freeze_time) { reward.redeem! }
    assert reward.redeemed?
    assert_in_delta freeze_time.to_f, reward.completed_at.to_f, 1
  end

  test "rejects invalid status" do
    assert_raises(ArgumentError) do
      Reward.new(status: "bogus")
    end
  end
end
