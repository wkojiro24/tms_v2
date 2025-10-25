# S3 コントローラ実装（app/controllers/vehicle_aliases_controller.rb：丸ごと）
class VehicleAliasesController < ApplicationController
  before_action :set_vehicle

  def create
    code = params.require(:code)
    @vehicle.claim_alias!(code) # 他車の同通称を自動で非アクティブ化
    redirect_to @vehicle, notice: "通称「#{code}」を現役として割り当てました。"
  rescue => e
    redirect_to @vehicle, alert: "通称の割当に失敗：#{e.message}"
  end

  def destroy
    alias_rec = @vehicle.vehicle_aliases.find(params[:id])
    alias_rec.update!(active: false)
    redirect_to @vehicle, notice: "通称「#{alias_rec.code}」を非アクティブにしました。"
  rescue => e
    redirect_to @vehicle, alert: "削除に失敗：#{e.message}"
  end

  private
  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
  end
end
