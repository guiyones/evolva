class AddFocusedQuestToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :focused_quest,
                  foreign_key: { to_table: :quests },
                  null: true
  end
end
