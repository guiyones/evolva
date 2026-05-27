require "test_helper"

class CheckinsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "new requires a challenge" do
    get new_challenge_checkin_path(challenges(:active_solo))
    assert_response :success
  end

  test "create records a checkin" do
    challenge = challenges(:active_solo)
    challenge.checkins.destroy_all

    assert_difference -> { challenge.checkins.count }, 1 do
      post challenge_checkins_path(challenge), params: { checkin: { feeling: "ok", note: "vamos" } }
    end
    assert_redirected_to challenge
  end

  test "create rejects same-day duplicate" do
    challenge = challenges(:active_solo)
    challenge.checkins.create!(day_number: 99, feeling: "ok")

    assert_no_difference -> { challenge.checkins.count } do
      post challenge_checkins_path(challenge), params: { checkin: { feeling: "ok" } }
    end
    assert_redirected_to challenge
  end
end
