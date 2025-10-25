# db/migrate/20251025023404_reset_fleet_core_and_purchase.rb
class ResetFleetCoreAndPurchase < ActiveRecord::Migration[7.1]
  def change
    # 既存の Vehicle 系を一旦クリーンに（合意済み）
    drop_table :vehicle_aliases, if_exists: true
    drop_table :mountings,       if_exists: true
    drop_table :tanks,           if_exists: true
    drop_table :vehicles,        if_exists: true

    # --- Vehicles ---
    create_table :vehicles do |t|
      t.string  :kind, null: false
      t.string  :number_plate
      t.string  :nickname
      t.string  :maker
      t.string  :model
      t.date    :first_registered_on
      t.integer :max_payload_kg
      t.integer :curb_weight_kg
      t.integer :odometer_km
      t.string  :axle_config_text
      t.integer :tire_count
      t.string  :status, default: "active"
      t.string  :depot_name
      t.string  :manager_name
      t.string  :manager_contact
      t.string  :cover_image_url
      t.text    :note
      t.timestamps
    end
    add_index :vehicles, :kind
    add_index :vehicles, :number_plate

    # --- Tanks ---
    create_table :tanks do |t|
      t.string  :serial_no
      t.string  :maker
      t.date    :first_registered_on
      t.string  :material_detail
      t.string  :lining
      t.string  :compartments
      t.string  :pressure_rating
      t.string  :valves
      t.integer :capacity_l
      t.integer :curb_weight_kg
      t.string  :current_cargo
      t.string  :current_shipper
      t.string  :depot_name
      t.string  :manager_name
      t.string  :manager_contact
      t.string  :cover_image_url
      t.text    :note
      t.timestamps
    end
    add_index :tanks, :serial_no

    # --- Mountings (Tank <-> Vehicle 装着履歴) ---
    create_table :mountings do |t|
      t.references :tank,    null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.date    :mounted_on, null: false
      t.date    :removed_on
      t.text    :note
      t.timestamps
    end
    add_index :mountings, [:tank_id, :vehicle_id, :mounted_on], name: "idx_mountings_key"

    # --- PurchaseRecord（購入記録：ポリモーフィック） ---
    create_table :purchase_records do |t|
      t.string  :asset_type,      null: false   # "Vehicle"/"Tank"
      t.bigint  :asset_id,        null: false
      t.date    :purchased_on,    null: false
      t.string  :vendor_name,     null: false
      t.integer :total_price_yen, null: false
      t.integer :base_price_yen
      t.integer :tax_yen
      t.string  :payment_terms
      t.string  :funding
      t.string  :contract_ref
      t.date    :warranty_until
      t.string  :initial_condition
      t.string  :document_url
      t.text    :note
      t.timestamps
    end
    add_index :purchase_records, [:asset_type, :asset_id, :purchased_on], name: "idx_pr_asset_date"

    # --- MaintenanceRecord（整備・修理：ポリモーフィック） ---
    create_table :maintenance_records do |t|
      t.string  :asset_type,   null: false
      t.bigint  :asset_id,     null: false
      t.date    :performed_on, null: false
      t.string  :title,        null: false
      t.string  :category
      t.text    :detail
      t.integer :cost_yen
      t.string  :vendor
      t.decimal :downtime_hours, precision: 6, scale: 2
      t.integer :odometer_km
      t.date    :warranty_until
      t.string  :severity
      t.string  :status, default: "done"
      t.string  :evidence_url
      t.text    :note
      t.timestamps
    end
    add_index :maintenance_records, [:asset_type, :asset_id, :performed_on], name: "idx_mr_asset_date"

    # --- Inspections（検査：ポリモーフィック） ---
    create_table :inspections do |t|
      t.string  :asset_type,   null: false
      t.bigint  :asset_id,     null: false
      t.string  :kind,         null: false
      t.date    :inspected_on, null: false
      t.date    :valid_until
      t.string  :result
      t.date    :correct_by
      t.string  :vendor
      t.string  :certificate_ref
      t.text    :note
      t.timestamps
    end
    add_index :inspections, [:asset_type, :asset_id, :valid_until], name: "idx_insp_asset_valid"

    # --- Attachments（写真・証憑：ポリモーフィック） ---
    create_table :attachments do |t|
      t.string  :asset_type, null: false
      t.bigint  :asset_id,   null: false
      t.string  :kind,       null: false     # photo/document/certificate
      t.string  :subkind
      t.string  :title
      t.date    :issued_on
      t.date    :valid_until
      t.string  :file_url,   null: false
      t.string  :thumb_url
      t.string  :uploaded_by
      t.text    :note
      t.timestamps
    end
    add_index :attachments, [:asset_type, :asset_id]
  end
end

