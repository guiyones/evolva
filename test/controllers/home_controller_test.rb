require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when unauthenticated" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "renders index when signed in" do
    sign_in_as users(:one)
    get root_path
    assert_response :success
    assert_select "p", text: /Bem-vindo/
  end
end
