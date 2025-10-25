class Vehicle < ApplicationRecord
  has_many :vehicle_aliases, dependent: :destroy  
  validates :name, :number_plate, presence: true
  validates :number_plate, uniqueness: true
  validates :vehicle_code, uniqueness: true, allow_nil: true
  before_validation { self.vehicle_code ||= to_vehicle_code(number_plate) }
  scope :active,   -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  def archived? = archived_at.present?
  def to_vehicle_code(str)
    return nil if str.blank?
    str.to_s.tr("０-９Ａ-Ｚａ-ｚ 　ー‐−–—","0-9A-Za-z     -----")
       .gsub(/\p{Space}+/, "").gsub(/[^\p{Alnum}]/,"").upcase.presence
  end
  # 同じ通称codeを他車から外し、自車に現役で付与
  def claim_alias!(raw_code, kind: :short_label)
    code = VehicleAlias.normalize(raw_code)
    raise ArgumentError, "通称が空です" if code.blank?
    ApplicationRecord.transaction do
      VehicleAlias.active.where(code: code).update_all(active: false)
      vehicle_aliases.create!(code: code, kind: kind, active: true)
    end
  end

end
