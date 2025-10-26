# app/controllers/tanks_controller.rb
class TanksController < ApplicationController
  before_action :set_tank, only: [:show, :edit, :update]
  before_action :load_vehicles, only: [:new, :edit, :create, :update]

  def index
    @tanks = Tank.order(id: :desc).limit(50)
  end
  def new
    @tank = Tank.new
  end

  def create
    @tank = Tank.new(tank_params)
    if @tank.save
      redirect_to tanks_path, notice: "タンクを登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end
  def edit; end

  def update
    if @tank.update(tank_params)
      notice =
        if params.dig(:tank, :vehicle_id).present?
          v = @tank.vehicle
          "割り当て完了：#{v&.number_plate || '未搭載'} ⇐ タンク #{@tank.serial_no}"
        else
          "タンクを更新しました。"
        end

      redirect_to(params[:return_to].presence || @tank, notice: notice)
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def show
    @tank = Tank.find(params[:id])
    @purchase_records = @tank.purchase_records.order(id: :desc).limit(100)
  end

  private

  def set_tank
    @tank = Tank.find(params[:id])
  end

  def load_vehicles
    @vehicles = Vehicle.order(:id)
  end

  def tank_params
    params.require(:tank).permit(
      :serial_no,
      :maker,
      :material_detail,
      :compartments,
      :manufactured_on,
      :current_cargo,
      :vehicle_id   # ← これが無いと割当が保存されません
    )
  end
end
