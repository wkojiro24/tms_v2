class EnsureItemsUniqueByNameAndAbove < ActiveRecord::Migration[7.2]
  def up
    # 古い index を「名前」で安全に外す
    remove_index :items, name: "index_items_on_row_and_above" if index_name_exists?(:items, "index_items_on_row_and_above")
    remove_index :items, name: "index_items_on_name"          if index_name_exists?(:items, "index_items_on_name")

    # 参照用（非ユニーク）index（無ければ作る）
    add_index :items, :name unless index_exists?(:items, :name)

    # 開発では一度データを空にしておくと重複で失敗しません（済ならスキップ可）
    # PayrollCell.delete_all; Item.delete_all はコンソール or runner で別途実行

    # 新しい一意制約: (name, above_basic)
    unless index_exists?(:items, [:name, :above_basic], name: "index_items_on_name_and_above_basic", unique: true)
      add_index :items, [:name, :above_basic], unique: true, name: "index_items_on_name_and_above_basic"
    end
  end

  def down
    remove_index :items, name: "index_items_on_name_and_above_basic" if index_name_exists?(:items, "index_items_on_name_and_above_basic")
    remove_index :items, :name                                       if index_exists?(:items, :name)
    # 必要なら旧 index を戻すが、今回は省略
  end
end

