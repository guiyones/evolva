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

  test "user can have a focused_quest" do
    user = users(:one)
    quest = quests(:leitura)
    user.update!(focused_quest: quest)
    assert_equal quest, user.reload.focused_quest
  end

  test "rejects focused_quest belonging to another user" do
    user = users(:one)
    other_quest = users(:two).quests.create!(title: "Outra", status: :active)
    user.focused_quest = other_quest
    assert_not user.valid?
    assert_includes user.errors[:focused_quest], "deve pertencer a você"
  end

  test "rejects focused_quest that is completed" do
    user = users(:one)
    user.focused_quest = quests(:completada)
    assert_not user.valid?
    assert_includes user.errors[:focused_quest], "precisa estar ativa"
  end
end
