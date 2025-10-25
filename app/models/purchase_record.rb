# app/models/purchase_record.rb
class PurchaseRecord < ApplicationRecord
  belongs_to :asset, polymorphic: true, optional: true  # ここを optional に
  validates :asset_type, :asset_id,
            presence: { message: "（車両/タンク）を選択してください" }
  validates :purchased_on, :vendor_name, :total_price_yen, presence: true
end
