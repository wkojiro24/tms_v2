class CreatePeriods < ActiveRecord::Migration[7.2]
  def change
    create_table :periods do |t|
      t.integer :year,  null: false
      t.integer :month, null: false
      t.timestamps
    end
  add_index :periods, [:year, :month], unique: true 
  end
end
