class Inspection < ApplicationRecord
  belongs_to :asset, polymorphic: true
  validates :kind, :inspected_on, presence: true
end
