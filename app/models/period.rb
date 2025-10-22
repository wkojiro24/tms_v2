class Period < ApplicationRecord
  validates :year,  presence: true, numericality: { only_integer: true, greater_than: 2000 }
  validates :month, presence: true, numericality: { only_integer: true, in: 1..12 }
  validates :month, uniqueness: { scope: :year }  # (year, month) でユニーク

end
