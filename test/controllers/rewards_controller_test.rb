require "test_helper"

class RewardsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "show renders" do
    get reward_path(rewards(:unlocked_one))
    assert_response :success
  end

  test "redeem unlocked reward marks redeemed" do
    reward = rewards(:unlocked_one)
    patch redeem_reward_path(reward)
    assert reward.reload.redeemed?
    assert_redirected_to reward
  end

  test "redeem locked reward does nothing" do
    reward = rewards(:locked_one)
    patch redeem_reward_path(reward)
    assert reward.reload.locked?
    assert_redirected_to reward
  end
end
