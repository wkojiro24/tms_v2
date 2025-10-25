class Item < ApplicationRecord
  has_many :payroll_cells, dependent: :destroy
  validates :name,        presence: true
  validates :above_basic, inclusion: { in: [ true, false ] }  # nil を禁止
  validates :name, uniqueness: { scope: :above_basic }      # 「名前×上下」で一意
  # 管理順序（position）→ 既存row_index → 名前
  scope :ordered, -> { order(Arel.sql("COALESCE(position, row_index, 999999) ASC"), :name) }
end
