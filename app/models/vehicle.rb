class Vehicle < ApplicationRecord
  include Assetable
  has_many :mountings, dependent: :restrict_with_exception
  has_many :tanks, through: :mountings
  enum :kind, { head: "head", chassis: "chassis" }
  validates :kind, presence: true

end
