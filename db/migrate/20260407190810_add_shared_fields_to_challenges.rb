class AddSharedFieldsToChallenges < ActiveRecord::Migration[8.1]
  def change
    add_column :challenges, :challenge_type, :string
    add_column :challenges, :invite_token, :string
  end
end
