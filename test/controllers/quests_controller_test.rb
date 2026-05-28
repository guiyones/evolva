require "test_helper"

class QuestsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "index renders" do
    get quests_path
    assert_response :success
  end

  test "show renders own quest" do
    get quest_path(quests(:leitura))
    assert_response :success
  end

  test "new renders form" do
    get new_quest_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference -> { Current.user.quests.count }, 1 do
      post quests_path, params: { quest: { title: "Nova jornada" } }
    end
  end

  test "create with invalid params re-renders" do
    assert_no_difference -> { Quest.count } do
      post quests_path, params: { quest: { title: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "attach_challenge links a challenge to the quest" do
    quest = quests(:leitura)
    challenge = challenges(:active_solo)
    post attach_challenge_quest_path(quest), params: { challenge_id: challenge.id }
    assert_equal quest.id, challenge.reload.quest_id
    assert challenge.planned?
  end

  test "destroy removes quest" do
    quest = quests(:completada)
    assert_difference -> { Quest.count }, -1 do
      delete quest_path(quest)
    end
  end

  test "focus sets focused_quest on current user" do
    quest = quests(:leitura)
    post focus_quest_path(quest)
    assert_redirected_to root_path
    assert_equal quest, users(:one).reload.focused_quest
  end

  test "focus forbids quest from another user" do
    other_quest = users(:two).quests.create!(title: "Outra", status: :active)
    post focus_quest_path(other_quest)
    assert_response :not_found
  end

  test "focus on completed quest is rejected" do
    post focus_quest_path(quests(:completada))
    assert_redirected_to quest_path(quests(:completada))
    assert_nil users(:one).reload.focused_quest
  end
end
