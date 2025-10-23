class AddAboveBasicToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :above_basic, :boolean
    add_index  :items, [:name, :above_basic], unique: true, name: "index_items_on_name_and_above_basic"
  end
end
