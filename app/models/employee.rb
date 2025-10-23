class Employee < ApplicationRecord
  has_many :payroll_cells, dependent: :destroy
  validates :code, presence: true, uniqueness: true

end
