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

ActiveRecord::Schema[7.2].define(version: 2025_10_24_043022) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "employees", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_employees_on_code", unique: true
  end

  create_table "item_orders", force: :cascade do |t|
    t.bigint "period_id", null: false
    t.bigint "item_id", null: false
    t.integer "row_index", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_orders_on_item_id"
    t.index ["period_id", "item_id"], name: "index_item_orders_on_period_id_and_item_id", unique: true
    t.index ["period_id"], name: "index_item_orders_on_period_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "row_index"
    t.integer "position"
    t.boolean "above_basic"
    t.index ["name", "above_basic"], name: "index_items_on_name_and_above_basic", unique: true
    t.index ["name"], name: "index_items_on_name"
    t.index ["position"], name: "index_items_on_position"
  end

  create_table "payroll_cells", force: :cascade do |t|
    t.bigint "period_id", null: false
    t.bigint "employee_id", null: false
    t.bigint "item_id", null: false
    t.string "raw"
    t.decimal "amount", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_payroll_cells_on_employee_id"
    t.index ["item_id"], name: "index_payroll_cells_on_item_id"
    t.index ["period_id", "employee_id", "item_id"], name: "idx_payroll_cells_unique", unique: true
    t.index ["period_id", "employee_id", "item_id"], name: "index_cells_on_period_employee_item", unique: true
    t.index ["period_id"], name: "index_payroll_cells_on_period_id"
  end

  create_table "periods", force: :cascade do |t|
    t.integer "year", null: false
    t.integer "month", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year", "month"], name: "index_periods_on_year_and_month", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "name"
    t.string "number_plate"
    t.string "manufacturer"
    t.string "model_code"
    t.integer "year"
    t.integer "mileage_km"
    t.datetime "archived_at"
    t.string "vehicle_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vehicle_code"], name: "index_vehicles_on_vehicle_code"
  end

  add_foreign_key "item_orders", "items"
  add_foreign_key "item_orders", "periods"
  add_foreign_key "payroll_cells", "employees"
  add_foreign_key "payroll_cells", "items"
  add_foreign_key "payroll_cells", "periods"
end
