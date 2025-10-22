class PayrollCell < ApplicationRecord
  belongs_to :period
  belongs_to :employee
  belongs_to :item
  
  validates :period_id, :employee_id, :item_id, presence: true
  validates :item_id, uniqueness: { scope: [:period_id, :employee_id] }
end
