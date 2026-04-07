class AddParentChallengeIdToChallenges < ActiveRecord::Migration[8.1]
  def change
    add_column :challenges, :parent_challenge_id, :integer
  end
end
