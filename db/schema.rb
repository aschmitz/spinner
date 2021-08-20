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

ActiveRecord::Schema.define(version: 2017_08_25_224232) do

  create_table "library_tracks", force: :cascade do |t|
    t.integer "user_id"
    t.integer "track_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "index_library_tracks_on_track_id"
    t.index ["user_id"], name: "index_library_tracks_on_user_id"
  end

  create_table "played_songs", force: :cascade do |t|
    t.integer "track_id"
    t.integer "user_id"
    t.datetime "played_at"
    t.boolean "skipped"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tlid"
    t.index ["track_id"], name: "index_played_songs_on_track_id"
    t.index ["user_id"], name: "index_played_songs_on_user_id"
  end

  create_table "queue_entries", force: :cascade do |t|
    t.integer "user_id"
    t.integer "track_id"
    t.integer "sequence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tlid"
    t.index ["track_id"], name: "index_queue_entries_on_track_id"
    t.index ["user_id"], name: "index_queue_entries_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "track_id"
    t.integer "user_id"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id", "user_id"], name: "index_ratings_on_track_id_and_user_id", unique: true
    t.index ["track_id"], name: "index_ratings_on_track_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "title"
    t.integer "length"
    t.string "uri"
    t.text "details"
    t.integer "volume", default: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uri"], name: "index_tracks_on_uri", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_present"
    t.boolean "in_room", default: true
    t.integer "queue_entries_count", default: 0
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
