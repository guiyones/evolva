require "test_helper"

class HistoryControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "index renders completed and finished" do
    get history_path
    assert_response :success
    assert_select "*", text: /Meditacao/
    assert_select "*", text: /Diario/
  end
end
