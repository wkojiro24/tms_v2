# db/migrate/xxxxxx_simplify_pairing_add_vehicle_id_to_tanks.rb
class SimplifyPairingAddVehicleIdToTanks < ActiveRecord::Migration[7.1]
  def up
    add_reference :tanks, :vehicle, foreign_key: true, null: true

    execute <<~SQL
      CREATE UNIQUE INDEX index_tanks_on_vehicle_id_unique_when_present
      ON tanks (vehicle_id)
      WHERE vehicle_id IS NOT NULL;
    SQL

    # （任意）Mountingsが残っていれば現搭載をバックフィル
    if table_exists?(:mountings)
      execute <<~SQL
        UPDATE tanks
        SET vehicle_id = m.vehicle_id
        FROM mountings m
        WHERE m.tank_id = tanks.id AND m.removed_on IS NULL;
      SQL

      # Mountingsをもう使わない場合のみ削除
      drop_table :mountings, if_exists: true
    end
  end

  def down
    execute "DROP INDEX IF EXISTS index_tanks_on_vehicle_id_unique_when_present;"
    remove_reference :tanks, :vehicle, foreign_key: true
  end
end

