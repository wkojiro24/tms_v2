class AddUniqueIndexToItemsOnNameAndAboveBasic < ActiveRecord::Migration[7.2]
  # 既存インデックスがあっても落ちないように
  disable_ddl_transaction!

  def up
    unless index_exists?(:items, [:name, :above_basic], name: "index_items_on_name_and_above_basic")
      add_index :items, [:name, :above_basic],
                unique: true,
                name: "index_items_on_name_and_above_basic",
                algorithm: :concurrently
    end
  end

  def down
    if index_exists?(:items, [:name, :above_basic], name: "index_items_on_name_and_above_basic")
      remove_index :items, name: "index_items_on_name_and_above_basic", algorithm: :concurrently
    end
  end
end

