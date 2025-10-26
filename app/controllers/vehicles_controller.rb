# app/controllers/vehicles_controller.rb
class VehiclesController < ApplicationController
  include FleetPairsHelper

  def index
    @q     = params[:q].to_s.strip
    @depot = params[:depot].presence

    scope = Vehicle
              .includes(:tank) # ←N+1防止
              .order(Arel.sql("COALESCE(depot_name,'~') ASC, COALESCE(number_plate,'~') ASC"))

    scope = scope.where(depot_name: @depot) if @depot
    if @q.present?
      like = "%#{@q}%"
      scope = scope.where("number_plate ILIKE :x OR maker ILIKE :x OR nickname ILIKE :x", x: like)
    end

    @vehicles = scope
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
