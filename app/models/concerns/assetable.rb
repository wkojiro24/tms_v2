module Assetable
  extend ActiveSupport::Concern
  included do
    has_many :purchase_records,    as: :asset, dependent: :restrict_with_exception
    has_many :maintenance_records, as: :asset, dependent: :restrict_with_exception
    has_many :inspections,         as: :asset, dependent: :restrict_with_exception
    has_many :attachments,         as: :asset, dependent: :restrict_with_exception
  end
end
