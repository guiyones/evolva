require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when unauthenticated" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "renders 'no quests' state when user has no quests" do
    user = User.create!(email_address: "nq@example.com", password: "secret123")
    sign_in_as user
    get root_path
    assert_response :success
    assert_select "*", text: /sua primeira jornada/i
  end

  test "renders 'choose focus' state when user has active quests but none focused" do
    sign_in_as users(:one)
    get root_path
    assert_response :success
    assert_select "*", text: /Escolha uma jornada/i
  end

  test "renders focus card when user has a focused quest" do
    users(:one).update!(focused_quest: quests(:leitura))
    sign_in_as users(:one)
    get root_path
    assert_response :success
    assert_select "*", text: /Ler mais livros/
  end

  test "renders celebration when focused quest is completed" do
    users(:one).update_column(:focused_quest_id, quests(:completada).id)
    sign_in_as users(:one)
    get root_path
    assert_response :success
    assert_select "*", text: /Jornada concluída/
  end
end
