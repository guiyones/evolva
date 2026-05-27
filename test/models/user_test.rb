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

  test "#initials uses first letter of name when present" do
    assert_equal "M", User.new(name: "Maria", email_address: "x@example.com").initials
  end

  test "#initials falls back to first letter of email" do
    assert_equal "Z", User.new(email_address: "zezinho@example.com").initials
  end
end
