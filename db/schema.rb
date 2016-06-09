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

ActiveRecord::Schema.define(version: 20160609181006) do

  create_table "keycards", force: :cascade do |t|
    t.string   "number"
    t.string   "hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "member_id"
  end

  create_table "members", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.text     "notes"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "membership_type"
    t.string   "status"
    t.string   "access"
    t.datetime "start_date"
    t.string   "payment_type"
    t.boolean  "has_mail_service"
    t.string   "mailbox_number"
    t.string   "phone"
    t.string   "company"
    t.integer  "keycard_id"
    t.datetime "last_change_date"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "memberships", force: :cascade do |t|
    t.string   "type"
    t.string   "start_date"
    t.string   "datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
