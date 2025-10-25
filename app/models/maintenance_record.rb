class MaintenanceRecord < ApplicationRecord
  belongs_to :asset, polymorphic: true
  validates :performed_on, :title, presence: true 
end
