require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new renders form" do
    get new_registration_path
    assert_response :success
  end

  test "create signs the user in" do
    assert_difference -> { User.count }, 1 do
      post registration_path, params: {
        user: {
          email_address: "novo@example.com",
          password: "secret123",
          password_confirmation: "secret123",
          name: "Novo"
        }
      }
    end
    assert_redirected_to root_path
  end

  test "create with mismatched passwords re-renders" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: { email_address: "x@example.com", password: "a", password_confirmation: "b" }
      }
    end
    assert_response :unprocessable_entity
  end
end
