# frozen_string_literal: true
class Reports::MonthsController < ApplicationController
  def index
    @periods = Period.order(year: :desc, month: :desc)
  end

  def show
    @period = Period.find(params[:id])

    # DISTINCT + ORDER のPG制約回避：IDを先に取り出してから並べる
    emp_ids  = PayrollCell.where(period_id: @period.id).distinct.pluck(:employee_id)
    item_ids = PayrollCell.where(period_id: @period.id).distinct.pluck(:item_id)

    @employees = Employee.where(id: emp_ids).order(:code)
    @items     = Item.where(id: item_ids).order(:row_index, :name)

    # { [emp_id, item_id] => cell } のハッシュ
    @cell_by = PayrollCell.where(period_id: @period.id, employee_id: emp_ids, item_id: item_ids)
                          .includes(:employee, :item)
                          .index_by { |c| [c.employee_id, c.item_id] }
  end
end
