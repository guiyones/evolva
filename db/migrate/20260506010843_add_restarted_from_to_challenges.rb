class AddRestartedFromToChallenges < ActiveRecord::Migration[8.0]
  def change
    add_reference :challenges, :restarted_from,
                  foreign_key: { to_table: :challenges, on_delete: :nullify },
                  null: true
  end
end
