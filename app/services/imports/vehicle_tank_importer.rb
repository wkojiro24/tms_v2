# frozen_string_literal: true
module Imports
  class VehicleTankImporter
    Result = Struct.new(:ok, :processed, :created, :updated, :assigned, :skipped, :errors, keyword_init: true)

    # 日本語 → 属性キー のヘッダ対応
    HEADER_MAP = {
      "自動車登録番号" => :number_plate,
      "車両メーカー"   => :vehicle_maker,
      "初度"           => :first_registered_on,
      "シャーシ"       => :axle_config_text,
      "備考"           => :note,

      # タンク側
      "製番"           => :tank_serial,
      "タンク製造年月日" => :tank_mfg_on,
      "輸送製品名"     => :product_name,
      "タンク経過年数" => :tank_age_years,
      "材質"           => :material,
      "室数"           => :compartments,
      "タイヤ本数"     => :tire_count,
      "タンク汎用性"   => :tank_versatility
    }.freeze

    KIND_MAP = {
      "単車" => "chassis",
      "シャーシ" => "chassis",
      "ヘッド" => "head", "トラクタ" => "head", "トレーラーヘッド" => "head"
    }.freeze

    def import(xlsx_path)
      require "roo"
      xls   = Roo::Spreadsheet.open(xlsx_path)
      sheet = xls.sheet(0)

      header = sheet.row(1).map { |h| h.to_s.strip }
      idx    = header.map { |h| HEADER_MAP[h] }

      processed = created = updated = assigned = skipped = 0
      errors = []

      (2..sheet.last_row).each do |r|
        row = Hash[
          idx.zip(sheet.row(r)).map do |key, val|
            [key, val.is_a?(String) ? val.strip : val]
          end
        ].compact

        begin
          res = import_row(row)
          case res
          when :created  then processed += 1; created  += 1
          when :updated  then processed += 1; updated  += 1
          when :assigned then processed += 1; assigned += 1
          when :skipped  then skipped   += 1
          else                skipped   += 1
          end
        rescue => e
          skipped += 1
          errors << "Row#{r}: #{e.class} #{e.message}"
        end
      end

      ok = errors.empty?
      Result.new(ok:, processed:, created:, updated:, assigned:, skipped:, errors:)
    end

    private

    def import_row(row)
      # 1) 車両を確実に取得 or 生成
      plate = row[:number_plate].to_s.strip
      return :skipped if plate.blank?

      v = Vehicle.find_or_initialize_by(number_plate: plate)

      # kind 必須対策（Excelに無いなら既定で chassis）
      v.kind = normalize_kind(row[:kind]) || v.kind || "chassis"

      v.maker              = row[:vehicle_maker].presence || v.maker
      v.first_registered_on = to_date(row[:first_registered_on]) || v.first_registered_on
      v.axle_config_text   = row[:axle_config_text].presence || v.axle_config_text
      v.note               = row[:note].presence || v.note

      v_changed = v.changed?
      v.save!  # => Kind can't be blank などをここで検出

      # 2) タンク（製番などキーになる列があればここで更新）
      serial = row[:tank_serial].to_s.strip
      return (v_changed ? :updated : :skipped) if serial.blank?

      t = Tank.find_or_initialize_by(serial_no: serial)
      t.material       = row[:material].presence      || t.material
      t.compartments   = row[:compartments].presence  || t.compartments
      t.tire_count     = row[:tire_count].presence    || t.tire_count
      t.versatility    = row[:tank_versatility].presence || t.versatility
      t.mfg_on         = to_date(row[:tank_mfg_on])   || t.mfg_on
      t.product_name   = row[:product_name].presence  || t.product_name
      t.vehicle        = v  # 1-1 の現在割当

      t_status =
        if t.new_record?
          t.save!
          :created
        elsif t.changed?
          t.save!
          :updated
        else
          :assigned # 既に同じ割当なら assigned と数える
        end

      # 車両側の status を優先度で返す
      return :updated  if v_changed && t_status == :assigned
      return t_status
    end

    def normalize_kind(s)
      return if s.blank?
      KIND_MAP[s.to_s.strip] || s.to_s.strip.downcase
    end

    def to_date(v)
      case v
      when Date     then v
      when Time     then v.to_date
      when String   then (Date.parse(v) rescue nil)
      else nil
      end
    end
  end
end
