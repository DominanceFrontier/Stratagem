# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150326130119) do

  create_table "ais", force: :cascade do |t|
    t.string   "name"
    t.string   "language"
    t.string   "location"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ais", ["user_id", "created_at"], name: "index_ais_on_user_id_and_created_at"
  add_index "ais", ["user_id"], name: "index_ais_on_user_id"

  create_table "games", force: :cascade do |t|
    t.string   "name"
    t.string   "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matches", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "mario_id"
    t.string   "mario_type"
    t.integer  "luigi_id"
    t.string   "luigi_type"
    t.string   "result",      default: "open"
    t.text     "state",       default: "[[\" \",\" \",\" \"],[\" \",\" \",\" \"],[\" \",\" \",\" \"]]"
    t.text     "moveHistory", default: "[]"
    t.datetime "created_at",                                                                            null: false
    t.datetime "updated_at",                                                                            null: false
  end

  add_index "matches", ["game_id"], name: "index_matches_on_game_id"
  add_index "matches", ["luigi_type", "luigi_id"], name: "index_matches_on_luigi_type_and_luigi_id"
  add_index "matches", ["mario_type", "mario_id"], name: "index_matches_on_mario_type_and_mario_id"

  create_table "stats", force: :cascade do |t|
    t.integer  "player_id"
    t.string   "player_type"
    t.integer  "wins",        default: 0
    t.integer  "losses",      default: 0
    t.integer  "ties",        default: 0
    t.integer  "illegals",    default: 0
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "stats", ["player_type", "player_id"], name: "index_stats_on_player_type_and_player_id"

  create_table "users", force: :cascade do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
