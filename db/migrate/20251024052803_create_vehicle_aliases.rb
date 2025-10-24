class CreateVehicleAliases < ActiveRecord::Migration[7.2]
  def change
    create_table :vehicle_aliases do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.string  :code,  null: false
      t.integer :kind,  null: false, default: 0  # 0=short_label, 1=legacy_label
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :vehicle_aliases, :code
    # active=true の時だけ code を一意に（対応DBで有効）
    add_index :vehicle_aliases, :code,
              unique: true,
              where: "active = TRUE",
              name: "idx_vehicle_aliases_code_unique_when_active"
  end
end
