class CreateItemOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :item_orders do |t|
      t.references :period, null: false, foreign_key: true
      t.references :item,   null: false, foreign_key: true
      t.integer :row_index, null: false
      t.timestamps
    end
    add_index :item_orders, [ :period_id, :item_id ], unique: true
  end
end
