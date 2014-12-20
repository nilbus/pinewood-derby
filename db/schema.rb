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

ActiveRecord::Schema.define(version: 20130109190837) do

  create_table "contestants", force: true do |t|
    t.string   "name"
    t.boolean  "retired"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "heats", force: true do |t|
    t.integer  "sequence"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "runs", force: true do |t|
    t.integer  "contestant_id"
    t.integer  "heat_id"
    t.decimal  "time"
    t.integer  "lane"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "single_values", force: true do |t|
    t.string   "type"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
