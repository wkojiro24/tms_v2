class Reports::EmployeesController < ApplicationController
  # 一覧（Index）: 社員を選んで Show に遷移
  def index
    @employees = Employee.order(:code, :name)

    if params[:employee_id].present?
      redirect_to reports_employee_path(params[:employee_id]) and return
    end
  end

    # 個人（Show）: 月次推移を表示
    def show
      @employee = Employee.find_by(id: params[:id]) || Employee.find_by!(code: params[:id])

      months   = (params[:months].presence || 4).to_i
      months   = 1 if months < 1
      @periods = Period.order(year: :desc, month: :desc).limit(months).to_a

      # === ここから置き換え ===
      # 結合を外す：セルだけで取得
      rel = PayrollCell.where(employee: @employee, period: @periods)

      # セル側の item_id をそのまま使う（JOIN しない）
      item_ids = rel.distinct.pluck(:item_id)

      @items = Item.where(id: item_ids)
                  .order(Arel.sql("COALESCE(row_index, 999999), CASE WHEN above_basic THEN 0 ELSE 1 END, name"))

      # マップもセルだけで作る（JOIN しない）
      @cell_map = rel.select(:period_id, :item_id, :raw, :amount).to_a
                    .index_by { |c| [ c.period_id, c.item_id ] }
      # === 置き換えここまで ===
    end
end
