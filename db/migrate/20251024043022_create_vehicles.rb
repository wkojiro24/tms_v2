class CreateVehicles < ActiveRecord::Migration[7.2]
  def change
    create_table :vehicles do |t|
      t.string :name
      t.string :number_plate
      t.string :manufacturer
      t.string :model_code
      t.integer :year
      t.integer :mileage_km
      t.datetime :archived_at
      t.string :vehicle_code

      t.timestamps
    end
    add_index :vehicles, :vehicle_code
  end
end
