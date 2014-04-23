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

ActiveRecord::Schema.define(version: 20140422154038) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arguments", force: true do |t|
    t.string   "summary"
    t.text     "description"
    t.integer  "page_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "option"
  end

  create_table "credentials", force: true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "indirect_votes", force: true do |t|
    t.integer  "vote_id"
    t.integer  "argument_id"
    t.integer  "position"
    t.integer  "voted_for_position"
    t.boolean  "same_option"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "indirect_votes", ["argument_id"], name: "index_indirect_votes_on_argument_id", using: :btree
  add_index "indirect_votes", ["vote_id"], name: "index_indirect_votes_on_vote_id", using: :btree

  create_table "pages", force: true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "option1",    default: "pros"
    t.string   "option2",    default: "cons"
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "users", force: true do |t|
    t.string   "primary_email"
    t.string   "name"
    t.text     "urls"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "votes", force: true do |t|
    t.integer  "user_id"
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "vote"
    t.string   "ip"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
