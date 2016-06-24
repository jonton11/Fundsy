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

ActiveRecord::Schema.define(version: 20160602223941) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.string   "title"
    t.integer  "goal"
    t.text     "body"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.string   "address"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "aasm_state"
  end

  add_index "campaigns", ["aasm_state"], name: "index_campaigns_on_aasm_state", using: :btree
  add_index "campaigns", ["user_id"], name: "index_campaigns_on_user_id", using: :btree

  create_table "pledges", force: :cascade do |t|
    t.float    "amount"
    t.integer  "user_id"
    t.integer  "campaign_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "txn_id"
  end

  add_index "pledges", ["campaign_id"], name: "index_pledges_on_campaign_id", using: :btree
  add_index "pledges", ["user_id"], name: "index_pledges_on_user_id", using: :btree

  create_table "rewards", force: :cascade do |t|
    t.integer  "amount"
    t.text     "description"
    t.integer  "campaign_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "rewards", ["campaign_id"], name: "index_rewards_on_campaign_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "api_key"
    t.string   "uid"
    t.string   "provider"
    t.string   "twitter_token"
    t.string   "twitter_secret"
    t.text     "twitter_raw_data"
    t.string   "address"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "stripe_customer_id"
    t.string   "stripe_card_type"
    t.string   "stripe_card_last4"
    t.integer  "stripe_card_exp_month"
    t.integer  "stripe_card_exp_year"
  end

  add_index "users", ["api_key"], name: "index_users_on_api_key", unique: true, using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", using: :btree

  add_foreign_key "campaigns", "users"
  add_foreign_key "pledges", "campaigns"
  add_foreign_key "pledges", "users"
  add_foreign_key "rewards", "campaigns"
end
