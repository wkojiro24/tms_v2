class VehicleAlias < ApplicationRecord
  belongs_to :vehicle
  enum :kind, { short_label: 0, legacy_label: 1 }

  before_validation { self.code = VehicleAlias.normalize(code) }

  validates :code, presence: true
  validate  :active_code_uniqueness, if: :active?

  scope :active, -> { where(active: true) }

  def self.normalize(str)
    return nil if str.blank?
    str.to_s
      .tr("０-９Ａ-Ｚａ-ｚ 　ー‐−–—","0-9A-Za-z     -----") # 全角→半角
      .gsub(/\p{Space}+/, "")                                # 空白除去（NBSP含む）
      .upcase                                                # 英字は大文字
  end

  private
  def active_code_uniqueness
    return unless code.present?
    if VehicleAlias.where(code: code, active: true).where.not(id: id).exists?
      errors.add(:code, "は既に現役の車両に割当済みです")
    end
  end
end
