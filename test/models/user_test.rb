require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "#display_name falls back to email prefix titleized" do
    user = User.new(email_address: "joao.silva@example.com")
    assert_equal "Joao.Silva", user.display_name
  end

  test "#display_name uses name when present" do
    user = User.new(name: "Maria", email_address: "x@example.com")
    assert_equal "Maria", user.display_name
  end
end
