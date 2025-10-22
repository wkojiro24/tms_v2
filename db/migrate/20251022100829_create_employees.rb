class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :employees, :code, unique: true
  end
end
