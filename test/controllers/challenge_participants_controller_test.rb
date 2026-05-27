require "test_helper"

class ChallengeParticipantsControllerTest < ActionDispatch::IntegrationTest
  test "create via invite token copies the challenge for the invitee" do
    original = challenges(:active_solo)
    sign_in_as users(:two)

    assert_difference -> { Challenge.count }, 1 do
      get join_challenge_path(original.invite_token)
    end

    copy = Current.user.challenges.order(:created_at).last
    assert_equal original.id, copy.parent_challenge_id
    assert copy.shared?
    assert_redirected_to copy
  end

  test "create rejects existing participant" do
    original = challenges(:active_solo)
    sign_in_as users(:one)

    assert_no_difference -> { Challenge.count } do
      get join_challenge_path(original.invite_token)
    end
    assert_redirected_to original
  end

  test "destroy removes the participant" do
    sign_in_as users(:one)
    participant = challenge_participants(:one_active)

    assert_difference -> { ChallengeParticipant.count }, -1 do
      delete challenge_participant_path(participant)
    end
    assert_redirected_to root_path
  end
end
