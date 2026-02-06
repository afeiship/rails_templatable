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

ActiveRecord::Schema[8.1].define(version: 2026_02_06_224749) do
  create_table "posts", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "template_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "rails_templatable_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "templatable_id", null: false
    t.string "templatable_type", null: false
    t.integer "template_id", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id", "templatable_type", "templatable_id"], name: "index_templatable_assignments", unique: true
    t.index ["template_id"], name: "index_rails_templatable_assignments_on_template_id"
  end

  create_table "rails_templatable_templates", force: :cascade do |t|
    t.string "category", null: false
    t.text "content"
    t.integer "content_format", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_rails_templatable_templates_on_category"
  end

  create_table "work_logs", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "template_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "posts", "rails_templatable_templates", column: "template_id"
  add_foreign_key "rails_templatable_assignments", "rails_templatable_templates", column: "template_id"
  add_foreign_key "work_logs", "rails_templatable_templates", column: "template_id"
end
