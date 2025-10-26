class Tank < ApplicationRecord
  include Assetable
  # ▼ 現在の相手だけ（tanks.vehicle_id を前提）
  belongs_to :vehicle, optional: true

  # 1 車両につき 1 タンク（NULL は許容）※DB側でも部分一意インデックスを作成済みが前提
  validates :vehicle_id, uniqueness: true, allow_nil: true
end
