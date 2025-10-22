class AddRowIndexToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :row_index, :integer
  end
end
