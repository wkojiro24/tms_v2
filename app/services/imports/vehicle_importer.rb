# app/services/imports/vehicle_importer.rb
# frozen_string_literal: true

module Imports
  class VehicleImporter < BaseImporter
    def import(uploaded)
      sheet, headers = open_first_sheet(uploaded)
      created = updated = skipped = 0

      (2..sheet.last_row).each do |r|
        row = Hash[headers.zip(sheet.row(r))].transform_values { |v| v.is_a?(String) ? v.strip : v }
        next if row.values.compact.map(&:to_s).all?(&:blank?)

        name         = pick(row, %w[name 車名 名称])&.to_s&.strip
        number_plate = pick(row, %w[number_plate ナンバー 登録番号])&.to_s&.strip
        manufacturer = pick(row, %w[manufacturer メーカー])&.to_s&.strip
        model_code   = pick(row, %w[model_code 型式 形式])&.to_s&.strip
        year_raw     = pick(row, %w[year 年式])
        mileage_raw  = pick(row, %w[mileage_km 走行距離 走行km])

        if number_plate.blank?
          skipped += 1
          next
        end

        v = Vehicle.find_or_initialize_by(number_plate: number_plate)
        is_new = v.new_record?
        v.name         = name if name.present?
        v.manufacturer = manufacturer
        v.model_code   = model_code
        v.year         = to_i_or_nil(year_raw)
        v.mileage_km   = to_i_or_nil(mileage_raw)
        v.save!
        is_new ? created += 1 : updated += 1
      end

      { created: created, updated: updated, skipped: skipped }
    end
  end
end
