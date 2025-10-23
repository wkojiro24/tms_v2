class ItemOrder < ApplicationRecord
  belongs_to :period
  belongs_to :item
  validates :row_index, presence: true
end
