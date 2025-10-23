class PayrollCell < ApplicationRecord
  belongs_to :period
  belongs_to :employee
  belongs_to :item

  validates :period,   presence: true
  validates :employee, presence: true
  validates :item,     presence: true

  # 同じ月・社員・項目の二重登録禁止（DB ユニーク制約と二重化）
  validates :item_id, uniqueness: { scope: [:period_id, :employee_id] }

  # 金額カラムは数値または nil（時間系は raw 側で表現されるので amount は空でよい）
  validates :amount, numericality: { allow_nil: true }
  # raw は任意（ファイルの原文を持つため自由）
end
