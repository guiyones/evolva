class CreateChallengeParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :challenge_participants do |t|
      t.references :challenge, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
