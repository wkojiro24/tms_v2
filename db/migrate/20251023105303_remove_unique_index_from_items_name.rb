class RemoveUniqueIndexFromItemsName < ActiveRecord::Migration[7.2]
  def up
    # 旧: name 単体ユニークが残っているので外す
    remove_index :items, name: "index_items_on_name"

    # 参照用に非ユニークの name インデックスを付け直す（任意だが推奨）
    add_index :items, :name
  end

  def down
    # 元に戻す（必要なら）
    remove_index :items, :name
    add_index :items, :name, unique: true
  end
end
