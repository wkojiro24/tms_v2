class ReportsController < ApplicationController
  def employee
@employees = Employee.order(:code)
all_periods = Period.order(year: :desc, month: :desc).to_a  # 新しい月が先（左）

# ▼ 12ヶ月ウィンドウ + ページング
window_size = 12
page = params[:page].to_i rescue 0        # 0=最新の12ヶ月
start = page * window_size
@periods = all_periods.slice(start, window_size) || []
@has_prev = (start + window_size) < all_periods.length  # ◀︎ さらに古い月がある
@has_next = page > 0                                     # ▶︎ 新しい月に戻れる
@page     = page

    return if params[:employee_id].blank?

    @employee = @employees.find_by(id: params[:employee_id])
    return unless @employee

    # この社員の全セル（全期間・全項目）
    cells = PayrollCell.where(employee: @employee).includes(:period, :item)

    # 行（項目）を row_index → name で並べる（row_indexがnilは後ろ）
    @items = cells.map(&:item).uniq.sort_by { |it| [it.row_index || 9_999_999, it.name] }


    # 参照ハッシュ period_id→item_id→cell
    @cell_map = Hash.new { |h, k| h[k] = {} }
    cells.each { |c| @cell_map[c.period_id][c.item_id] = c }
  end
end
