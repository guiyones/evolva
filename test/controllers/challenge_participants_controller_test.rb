require "test_helper"

class ChallengeParticipantsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get challenge_participants_create_url
    assert_response :success
  end

  test "should get destroy" do
    get challenge_participants_destroy_url
    assert_response :success
  end
end
