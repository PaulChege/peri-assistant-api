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

ActiveRecord::Schema[8.0].define(version: 2025_08_13_141320) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "breaks", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "breakable_type", null: false
    t.bigint "breakable_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["breakable_type", "breakable_id"], name: "index_breaks_on_breakable"
    t.index ["breakable_type", "breakable_id"], name: "index_breaks_on_breakable_type_and_breakable_id"
    t.index ["end_date"], name: "index_breaks_on_end_date"
    t.index ["start_date"], name: "index_breaks_on_start_date"
    t.index ["user_id"], name: "index_breaks_on_user_id"
  end

  create_table "institutions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.integer "student_id"
    t.integer "duration"
    t.text "plan"
    t.integer "status"
    t.integer "charge"
    t.boolean "paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date_time"
    t.text "notes"
    t.index ["student_id"], name: "index_lessons_on_student_id"
  end

  create_table "reports", force: :cascade do |t|
    t.text "summary", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_date"], name: "index_reports_on_end_date"
    t.index ["start_date", "end_date"], name: "index_reports_on_start_date_and_end_date"
    t.index ["start_date"], name: "index_reports_on_start_date"
    t.index ["student_id"], name: "index_reports_on_student_id"
    t.check_constraint "end_date > start_date", name: "check_end_date_after_start_date"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "instruments"
    t.date "start_date"
    t.string "mobile_number"
    t.date "date_of_birth"
    t.text "goals"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "institution_id"
    t.jsonb "schedule", default: []
    t.integer "lesson_unit_charge", default: 0
    t.integer "status", default: 0, null: false
    t.index ["email", "user_id"], name: "index_students_on_email_and_user_id", unique: true
    t.index ["institution_id"], name: "index_students_on_institution_id"
    t.index ["mobile_number", "user_id"], name: "index_students_on_mobile_number_and_user_id", unique: true
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_id"
    t.string "google_photo_url"
    t.string "country"
    t.string "currency", default: "USD"
  end

  add_foreign_key "breaks", "users"
  add_foreign_key "reports", "students"
  add_foreign_key "students", "institutions"
end
