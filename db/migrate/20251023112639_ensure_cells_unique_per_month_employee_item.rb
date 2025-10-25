class EnsureCellsUniquePerMonthEmployeeItem < ActiveRecord::Migration[7.2]
  def change
    add_index :payroll_cells, [ :period_id, :employee_id, :item_id ],
              unique: true, name: "index_cells_on_period_employee_item"
  end
end
