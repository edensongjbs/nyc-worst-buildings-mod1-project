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

ActiveRecord::Schema.define(version: 2020_06_09_183130) do

  create_table "buildings", force: :cascade do |t|
    t.string "bbl"
    t.string "house_number"
    t.string "street_name"
    t.string "zip"
    t.string "building_class"
    t.string "story"
  end

  create_table "dob_violations", force: :cascade do |t|
    t.string "violation_category"
    t.string "violation_type"
    t.string "issue_date"
    t.string "disposition_date"
    t.string "disposition_comments"
    t.string "dob_violation_num"
    t.integer "building_id"
  end

  create_table "hpd_violations", force: :cascade do |t|
    t.string "novdescription"
    t.string "issue_date"
    t.string "status_id"
    t.string "status"
    t.string "novid"
    t.string "violation_num"
    t.integer "building_id"
  end

end
