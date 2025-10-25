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

ActiveRecord::Schema[7.2].define(version: 2025_10_25_023404) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", force: :cascade do |t|
    t.string "asset_type", null: false
    t.bigint "asset_id", null: false
    t.string "kind", null: false
    t.string "subkind"
    t.string "title"
    t.date "issued_on"
    t.date "valid_until"
    t.string "file_url", null: false
    t.string "thumb_url"
    t.string "uploaded_by"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_type", "asset_id"], name: "index_attachments_on_asset_type_and_asset_id"
  end

  create_table "employees", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_employees_on_code", unique: true
  end

  create_table "inspections", force: :cascade do |t|
    t.string "asset_type", null: false
    t.bigint "asset_id", null: false
    t.string "kind", null: false
    t.date "inspected_on", null: false
    t.date "valid_until"
    t.string "result"
    t.date "correct_by"
    t.string "vendor"
    t.string "certificate_ref"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_type", "asset_id", "valid_until"], name: "idx_insp_asset_valid"
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

  create_table "maintenance_records", force: :cascade do |t|
    t.string "asset_type", null: false
    t.bigint "asset_id", null: false
    t.date "performed_on", null: false
    t.string "title", null: false
    t.string "category"
    t.text "detail"
    t.integer "cost_yen"
    t.string "vendor"
    t.decimal "downtime_hours", precision: 6, scale: 2
    t.integer "odometer_km"
    t.date "warranty_until"
    t.string "severity"
    t.string "status", default: "done"
    t.string "evidence_url"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_type", "asset_id", "performed_on"], name: "idx_mr_asset_date"
  end

  create_table "mountings", force: :cascade do |t|
    t.bigint "tank_id", null: false
    t.bigint "vehicle_id", null: false
    t.date "mounted_on", null: false
    t.date "removed_on"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tank_id", "vehicle_id", "mounted_on"], name: "idx_mountings_key"
    t.index ["tank_id"], name: "index_mountings_on_tank_id"
    t.index ["vehicle_id"], name: "index_mountings_on_vehicle_id"
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

  create_table "purchase_records", force: :cascade do |t|
    t.string "asset_type", null: false
    t.bigint "asset_id", null: false
    t.date "purchased_on", null: false
    t.string "vendor_name", null: false
    t.integer "total_price_yen", null: false
    t.integer "base_price_yen"
    t.integer "tax_yen"
    t.string "payment_terms"
    t.string "funding"
    t.string "contract_ref"
    t.date "warranty_until"
    t.string "initial_condition"
    t.string "document_url"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_type", "asset_id", "purchased_on"], name: "idx_pr_asset_date"
  end

  create_table "tanks", force: :cascade do |t|
    t.string "serial_no"
    t.string "maker"
    t.date "first_registered_on"
    t.string "material_detail"
    t.string "lining"
    t.string "compartments"
    t.string "pressure_rating"
    t.string "valves"
    t.integer "capacity_l"
    t.integer "curb_weight_kg"
    t.string "current_cargo"
    t.string "current_shipper"
    t.string "depot_name"
    t.string "manager_name"
    t.string "manager_contact"
    t.string "cover_image_url"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["serial_no"], name: "index_tanks_on_serial_no"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "kind", null: false
    t.string "number_plate"
    t.string "nickname"
    t.string "maker"
    t.string "model"
    t.date "first_registered_on"
    t.integer "max_payload_kg"
    t.integer "curb_weight_kg"
    t.integer "odometer_km"
    t.string "axle_config_text"
    t.integer "tire_count"
    t.string "status", default: "active"
    t.string "depot_name"
    t.string "manager_name"
    t.string "manager_contact"
    t.string "cover_image_url"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_vehicles_on_kind"
    t.index ["number_plate"], name: "index_vehicles_on_number_plate"
  end

  add_foreign_key "item_orders", "items"
  add_foreign_key "item_orders", "periods"
  add_foreign_key "mountings", "tanks"
  add_foreign_key "mountings", "vehicles"
  add_foreign_key "payroll_cells", "employees"
  add_foreign_key "payroll_cells", "items"
  add_foreign_key "payroll_cells", "periods"
end
