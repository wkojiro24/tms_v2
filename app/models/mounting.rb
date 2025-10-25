class Mounting < ApplicationRecord
  belongs_to :tank
  belongs_to :vehicle
  validates :mounted_on, presence: true
end
