# app/controllers/purchase_records_controller.rb
class PurchaseRecordsController < ApplicationController
  before_action :load_assets, only: [:new, :create]

  def index
    @purchase_records = PurchaseRecord.order(id: :desc).includes(:asset).limit(100)
  end

  def new
    @purchase_record = PurchaseRecord.new(purchased_on: Date.today)
  end

  def create
    attrs = pr_params

    # ここで "Vehicle:12" 形式を分解してセット
    if (ref = params.dig(:purchase_record, :asset_ref)).present?
      type, id = ref.split(":", 2)
      attrs[:asset_type] = type
      attrs[:asset_id]   = id
    end

    @purchase_record = PurchaseRecord.new(attrs)

    if @purchase_record.save
      redirect_to purchase_records_path, notice: "購入記録を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def pr_params
    params.require(:purchase_record).permit(
      :purchased_on, :vendor_name, :total_price_yen,
      :base_price_yen, :tax_yen, :payment_terms, :funding, :contract_ref,
      :warranty_until, :initial_condition, :document_url, :note
      # asset_type / asset_id は asset_ref からサーバ側でセット
    )
  end

  def load_assets
    @vehicles = Vehicle.order(id: :desc).limit(200)
    @tanks    = Tank.order(id: :desc).limit(200)
  end
end
