# db/migrate/XXXXXXXXXXXX_add_position_to_items.rb
class AddPositionToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :position, :integer
    add_index  :items, :position

    # 既存データの初期値: row_index を流用（nilは末尾に送る）
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE items SET position = COALESCE(row_index, 999999);
        SQL
      end
    end
  end
end
