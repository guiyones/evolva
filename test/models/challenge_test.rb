require "test_helper"

class ChallengeTest < ActiveSupport::TestCase
  test ".active returns only active challenges" do
    assert_includes Challenge.active, challenges(:active_solo)
    assert_not_includes Challenge.active, challenges(:completed_solo)
    assert_not_includes Challenge.active, challenges(:planned_in_quest)
    assert_not_includes Challenge.active, challenges(:finished_solo)
  end

  test ".planned returns only planned challenges" do
    assert_includes Challenge.planned, challenges(:planned_in_quest)
    assert_not_includes Challenge.planned, challenges(:active_solo)
  end

  test ".completed returns only completed challenges" do
    assert_includes Challenge.completed, challenges(:completed_solo)
    assert_not_includes Challenge.completed, challenges(:active_solo)
  end

  test ".finished returns only finished challenges" do
    assert_includes Challenge.finished, challenges(:finished_solo)
    assert_not_includes Challenge.finished, challenges(:active_solo)
  end

  test ".independent returns challenges without a quest" do
    assert_includes Challenge.independent, challenges(:active_solo)
    assert_not_includes Challenge.independent, challenges(:planned_in_quest)
  end

  test "rejects invalid status" do
    assert_raises(ArgumentError) do
      Challenge.new(status: "bogus")
    end
  end

  test "shared challenge auto-adds owner as participant on create" do
    user = users(:one)
    challenge = user.challenges.create!(
      title: "Compartilhado",
      duration_days: 10,
      challenge_type: "shared",
      status: :active
    )
    assert_includes challenge.participants, user
  end

  test "solo challenge does not create a participant on create" do
    user = users(:one)
    assert_no_difference -> { ChallengeParticipant.count } do
      user.challenges.create!(
        title: "Sozinho",
        duration_days: 10,
        challenge_type: "solo",
        status: :active
      )
    end
  end

  test "#share_with creates a copy for the user and adds them as participant of both" do
    original = challenges(:active_solo)
    invitee = users(:two)

    copy = nil
    assert_difference -> { Challenge.count }, 1 do
      assert_difference -> { ChallengeParticipant.count }, 2 do
        copy = original.share_with(invitee)
      end
    end

    assert_equal invitee, copy.user
    assert_equal original.id, copy.parent_challenge_id
    assert copy.shared?
    assert original.reload.shared?
    assert_includes original.participants, invitee
    assert_includes copy.participants, invitee
  end

  test "#start! transitions planned to active and sets started_at" do
    challenge = challenges(:planned_in_quest)
    assert challenge.planned?

    challenge.start!

    assert challenge.active?
    assert_not_nil challenge.started_at
  end

  test "#start! sets started_at on active challenge missing it" do
    challenge = challenges(:active_solo)
    challenge.update_column(:started_at, nil)

    challenge.start!

    assert_not_nil challenge.reload.started_at
  end

  test "#start! is a no-op for active challenges with started_at" do
    challenge = challenges(:active_solo)
    original_started_at = challenge.started_at

    challenge.start!

    assert_equal original_started_at.to_i, challenge.reload.started_at.to_i
  end

  test "#restart! creates a fresh active challenge linked to the original" do
    original = challenges(:finished_solo)

    new_challenge = nil
    assert_difference -> { original.user.challenges.count }, 1 do
      new_challenge = original.restart!
    end

    assert new_challenge.active?
    assert_equal original.id, new_challenge.restarted_from_id
    assert_equal original.title, new_challenge.title
    assert_equal original.duration_days, new_challenge.duration_days
    assert_not_nil new_challenge.started_at
  end
end
