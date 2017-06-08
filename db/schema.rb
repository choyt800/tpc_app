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

ActiveRecord::Schema.define(version: 20170608210433) do

  create_table "active_members", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "membership_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "payment_type"
    t.string   "notes"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "checkins", force: :cascade do |t|
    t.datetime "date"
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keycard_checkouts", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "keycard_id"
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "notes"
  end

  create_table "keycards", force: :cascade do |t|
    t.string   "number"
    t.string   "hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "status"
    t.text     "notes"
  end

  create_table "mail_services", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "mailbox_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text     "notes"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.decimal  "average_monthly_payment"
  end

  create_table "mailboxes", force: :cascade do |t|
    t.integer  "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.text     "notes"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "status"
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
    t.string   "role"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "notes"
    t.datetime "start_date"
    t.integer  "member_id"
    t.integer  "plan_id"
    t.datetime "end_date"
    t.string   "payment_type"
    t.string   "paid_by"
    t.decimal  "average_monthly_payment"
  end

  create_table "plans", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "name"
    t.string   "status"
    t.text     "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "day"
  end

end
