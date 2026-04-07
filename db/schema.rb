# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_07_203718) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "challenge_participants", force: :cascade do |t|
    t.bigint "challenge_id", null: false
    t.datetime "created_at", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["challenge_id"], name: "index_challenge_participants_on_challenge_id"
    t.index ["user_id"], name: "index_challenge_participants_on_user_id"
  end

  create_table "challenges", force: :cascade do |t|
    t.string "challenge_type"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_days"
    t.string "invite_token"
    t.integer "parent_challenge_id"
    t.bigint "quest_id"
    t.datetime "started_at"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["quest_id"], name: "index_challenges_on_quest_id"
    t.index ["user_id"], name: "index_challenges_on_user_id"
  end

  create_table "checkins", force: :cascade do |t|
    t.bigint "challenge_id", null: false
    t.datetime "created_at", null: false
    t.integer "day_number"
    t.string "feeling"
    t.text "note"
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_checkins_on_challenge_id"
  end

  create_table "quests", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "started_at"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_quests_on_user_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.bigint "challenge_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "quest_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["challenge_id"], name: "index_rewards_on_challenge_id"
    t.index ["quest_id"], name: "index_rewards_on_quest_id"
    t.index ["user_id"], name: "index_rewards_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "challenge_participants", "challenges"
  add_foreign_key "challenge_participants", "users"
  add_foreign_key "challenges", "quests"
  add_foreign_key "challenges", "users"
  add_foreign_key "checkins", "challenges"
  add_foreign_key "quests", "users"
  add_foreign_key "rewards", "challenges"
  add_foreign_key "rewards", "quests"
  add_foreign_key "rewards", "users"
  add_foreign_key "sessions", "users"
end
