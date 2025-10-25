# app/controllers/vehicles_controller.rb
class VehiclesController < ApplicationController
  def index
    @vehicles = Vehicle.order(id: :desc).limit(50)
  end
  def new
    @vehicle = Vehicle.new
  end
  def create
    @vehicle = Vehicle.new(vehicle_params)
    if @vehicle.save
      redirect_to vehicles_path, notice: "車両を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @vehicle = Vehicle.find(params[:id])
    @purchase_records = @vehicle.purchase_records.order(id: :desc).limit(100)
  end


  private
  def vehicle_params
    params.require(:vehicle).permit(
      :kind, :number_plate, :nickname, :maker, :model, :first_registered_on,
      :max_payload_kg, :curb_weight_kg, :odometer_km, :axle_config_text,
      :tire_count, :status, :depot_name, :manager_name, :manager_contact,
      :cover_image_url, :note
    )
  end
end
