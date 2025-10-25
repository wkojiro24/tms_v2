# app/controllers/tanks_controller.rb
class TanksController < ApplicationController
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

  def show
    @tank = Tank.find(params[:id])
    @purchase_records = @tank.purchase_records.order(id: :desc).limit(100)
  end

  private
  def tank_params
    params.require(:tank).permit(
      :serial_no, :maker, :first_registered_on, :material_detail, :lining,
      :compartments, :pressure_rating, :valves, :capacity_l, :curb_weight_kg,
      :current_cargo, :current_shipper, :depot_name, :manager_name,
      :manager_contact, :cover_image_url, :note
    )
  end
end
