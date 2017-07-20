# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170720184659) do

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
