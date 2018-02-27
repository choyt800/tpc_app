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

ActiveRecord::Schema.define(version: 20180223223336) do

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

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "super"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true
  add_index "admins", ["invitation_token"], name: "index_admins_on_invitation_token", unique: true
  add_index "admins", ["invitations_count"], name: "index_admins_on_invitations_count"
  add_index "admins", ["invited_by_id"], name: "index_admins_on_invited_by_id"
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true

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
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "notes"
    t.string   "payment_type"
    t.datetime "next_invoice_date"
    t.integer  "plan_id"
    t.string   "stripe_charge_id"
    t.boolean  "stripe_charge_refunded", default: false
    t.integer  "team_id"
  end

  add_index "keycard_checkouts", ["plan_id"], name: "index_keycard_checkouts_on_plan_id"

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
    t.string   "payment_type"
    t.datetime "next_invoice_date"
    t.integer  "plan_id"
    t.integer  "team_id"
  end

  add_index "mail_services", ["plan_id"], name: "index_mail_services_on_plan_id"

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
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
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
    t.string   "stripe_customer_id",    limit: 50
    t.string   "stripe_id"
    t.integer  "team_id"
    t.boolean  "team_active",                      default: true
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
    t.datetime "next_invoice_date"
    t.integer  "team_id"
  end

  create_table "plan_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "stripe_id"
    t.integer  "category_order"
    t.string   "plan_category_id"
    t.boolean  "deleted",          default: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.string   "permalink"
    t.text     "description"
    t.integer  "price"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "products", ["user_id"], name: "index_products_on_user_id"

  create_table "sales", force: :cascade do |t|
    t.string   "email"
    t.string   "guid"
    t.integer  "product_id"
    t.string   "stripe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sales", ["product_id"], name: "index_sales_on_product_id"

  create_table "tasks", force: :cascade do |t|
    t.string   "name"
    t.string   "status"
    t.text     "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "day"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "owner"
    t.string   "billing_email"
    t.string   "stripe_id"
    t.text     "notes"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "member_email"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
