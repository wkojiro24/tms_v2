class Vehicle < ApplicationRecord
  include Assetable

  # ▼ 現在の相手だけ（tanks.vehicle_id を前提）
  has_one :tank, dependent: :nullify

  enum :kind, { head: "head", chassis: "chassis" }
  validates :kind, presence: true
end

