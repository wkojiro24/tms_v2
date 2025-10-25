class PurchaseRecord < ApplicationRecord
  belongs_to :asset, polymorphic: true
  validates :purchased_on, :vendor_name, :total_price_yen, presence: true
end
