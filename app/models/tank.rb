class Tank < ApplicationRecord
  include Assetable
  has_many :mountings, dependent: :restrict_with_exception
  has_many :vehicles, through: :mountings
  def current_vehicle
    mountings.where(removed_on: nil).order(mounted_on: :desc).first&.vehicle
  end
end
