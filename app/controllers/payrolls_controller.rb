# app/controllers/payrolls_controller.rb
class PayrollsController < ApplicationController
  def index
    @periods   = Period.order(year: :desc, month: :desc)
    @employees = Employee.order(:code)

    # パラメータが来ていなければ画面だけ出す
    return if params[:period_id].blank? || params[:employee_id].blank?

    @period   = @periods.find_by(id: params[:period_id])
    @employee = @employees.find_by(id: params[:employee_id])
    return unless @period && @employee

    # その人・その月のセルを取得（項目付き）
    cells = PayrollCell
              .where(period: @period, employee: @employee)
              .includes(:item)

    # ★ 並び：row_index（nilは後ろ）→ name
    @items = cells.map(&:item).uniq.sort_by { |it| [it.row_index || 9_999_999, it.name] }
    @cell_by_item_id = cells.index_by { |c| c.item_id }
  end
end
