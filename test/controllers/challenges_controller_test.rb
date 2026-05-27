require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "index lists only independent challenges" do
    get challenges_path
    assert_response :success
    assert_select "h1, h2, .challenge-title", text: /corrida/i
  end

  test "show renders own challenge" do
    get challenge_path(challenges(:active_solo))
    assert_response :success
  end

  test "show forbids other user's challenge" do
    get challenge_path(challenges(:active_other_user))
    assert_response :not_found
  end

  test "new renders form" do
    get new_challenge_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference -> { Current.user.challenges.count }, 1 do
      post challenges_path, params: {
        challenge: { title: "Novo desafio", duration_days: 10, challenge_type: "solo" }
      }
    end
    assert_redirected_to Current.user.challenges.order(:created_at).last
  end

  test "create with invalid params re-renders" do
    assert_no_difference -> { Challenge.count } do
      post challenges_path, params: { challenge: { title: "", duration_days: 0 } }
    end
    assert_response :unprocessable_entity
  end

  test "update edits title" do
    challenge = challenges(:active_solo)
    patch challenge_path(challenge), params: { challenge: { title: "Renomeado" } }
    assert_redirected_to challenge
    assert_equal "Renomeado", challenge.reload.title
  end

  test "destroy removes challenge" do
    challenge = challenges(:active_solo)
    assert_difference -> { Challenge.count }, -1 do
      delete challenge_path(challenge)
    end
    assert_redirected_to challenges_path
  end

  test "restart creates a new active challenge linked to the original" do
    original = challenges(:finished_solo)
    assert_difference -> { Challenge.count }, 1 do
      post restart_challenge_path(original)
    end
    new_challenge = Challenge.order(:created_at).last
    assert new_challenge.active?
    assert_equal original.id, new_challenge.restarted_from_id
  end
end
