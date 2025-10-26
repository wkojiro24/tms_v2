# app/services/imports/vehicle_importer.rb
# frozen_string_literal: true
require "roo"
require "csv"

module Imports
  class VehicleImporter
    class Error < StandardError; end

    VEHICLE_SHEETS = %w[Vehicles 車両 車両一覧].freeze
    TANK_SHEETS    = %w[Tanks タンク タンク一覧].freeze

    # controller から呼ばれる想定
    # @return {created:, updated:, skipped:} 互換を維持（Vehicle 分）+ @meta に Tanks 統計を格納
    def import(file_param)
      path = ensure_local_path(file_param)
      ext  = File.extname(path).downcase

      @v_stats = { created: 0, updated: 0, skipped: 0 }
      @t_stats = { created: 0, updated: 0, skipped: 0 }
      @links   = 0

      case ext
      when ".xlsx", ".xls"
        book = Roo::Spreadsheet.open(path)
        import_vehicles_sheet(book)
        import_tanks_sheet(book) # ← シートが無ければスキップ
      when ".csv"
        import_csv_as_vehicles(path)
      else
        raise Error, "対応拡張子は .xlsx / .xls / .csv です（受領: #{ext}）"
      end

      # 既存のコントローラ互換（vehicles の統計を返す）
      { created: @v_stats[:created], updated: @v_stats[:updated], skipped: @v_stats[:skipped],
        tanks: @t_stats, links_updated: @links }
    end

    private

    # ---------- Vehicles ----------
    def import_vehicles_sheet(book)
      sheet = find_sheet(book, VEHICLE_SHEETS)
      return unless sheet

      headers = norm_headers(sheet.row(1))
      (2..sheet.last_row).each do |r|
        row = row_hash(headers, sheet.row(r))
        next if blank_row?(row)

        key = val(row, "number_plate")
        unless key
          @v_stats[:skipped] += 1
          next
        end

        v = Vehicle.find_or_initialize_by(number_plate: key)
        was_new = v.new_record?
        assign_vehicle_fields(v, row)

        if v.changed?
          v.save!
          was_new ? @v_stats[:created] += 1 : @v_stats[:updated] += 1
        else
          @v_stats[:skipped] += 1
        end

        # === ここから：同一行にタンク列があれば“現在タンク”も処理 ===
        upsert_tank_from_vehicle_row(v, row)
      end
    end

   def upsert_tank_from_vehicle_row(vehicle, row)
      # どれかが入っていればタンク列ありとみなす
      sn = val(row, "serial_no") || val(row, "tank_serial_no")
      tm = val(row, "maker")     || val(row, "tank_maker")
      return unless sn || tm || val(row, "tank_first_registered_on") || val(row, "material_detail") || val(row, "capacity_l")

      t = Tank.find_or_initialize_by(serial_no: sn.presence || "__NO_SN__#{vehicle.number_plate}") # 製番が無い行の一時キー
      was_new = t.new_record?

      # マッピング：tank_ 接頭辞も許容
      t.maker               = val(row, "tank_maker") || val(row, "maker") || t.maker
      t.first_registered_on = parse_date(val(row, "tank_first_registered_on") || val(row, "first_registered_on")) || t.first_registered_on
      t.material_detail     = val(row, "material_detail") || val(row, "tank_material_detail") || t.material_detail
      t.lining              = val(row, "lining") || val(row, "tank_lining") || t.lining
      t.compartments        = to_i_or_nil(val(row, "compartments") || val(row, "tank_compartments")) || t.compartments
      t.pressure_rating     = val(row, "pressure_rating") || val(row, "tank_pressure_rating") || t.pressure_rating
      t.valves              = val(row, "valves") || val(row, "tank_valves") || t.valves
      t.capacity_l          = to_i_or_nil(val(row, "capacity_l") || val(row, "tank_capacity_l")) || t.capacity_l
      t.curb_weight_kg      = to_i_or_nil(val(row, "curb_weight_kg") || val(row, "tank_curb_weight_kg")) || t.curb_weight_kg
      t.current_cargo       = val(row, "current_cargo") || val(row, "tank_current_cargo") || t.current_cargo
      t.current_shipper     = val(row, "current_shipper") || val(row, "tank_current_shipper") || t.current_shipper
      t.cover_image_url     = val(row, "tank_cover_image_url") || val(row, "cover_image_url") || t.cover_image_url
      t.note                = (val(row, "tank_note") || t.note).to_s

      # “現在タンク”としてこの車両に割当
      if t.vehicle_id != vehicle.id
        t.vehicle = vehicle
        @links += 1
      end

      if t.changed?
        t.save!
        was_new ? @t_stats[:created] += 1 : @t_stats[:updated] += 1
      else
        @t_stats[:skipped] += 1
      end
    end


    def assign_vehicle_fields(v, row)
      v.kind                = val(row, "kind") || v.kind
      v.maker               = val(row, "maker")
      v.first_registered_on = parse_date(val(row, "first_registered_on")) || v.first_registered_on
      v.depot_name          = val(row, "depot_name")
      v.nickname            = val(row, "nickname")
      v.max_payload_kg      = to_i_or_nil(val(row, "max_payload_kg"))
      v.tire_count          = to_i_or_nil(val(row, "tire_count"))
      v.note                = (val(row, "note") || v.note).to_s
    end

    # ---------- Tanks（あれば取り込む） ----------
    def import_tanks_sheet(book)
      sheet = find_sheet(book, TANK_SHEETS)
      return unless sheet

      headers = norm_headers(sheet.row(1))
      (2..sheet.last_row).each do |r|
        row = row_hash(headers, sheet.row(r))
        next if blank_row?(row)

        key = val(row, "serial_no")
        unless key
          @t_stats[:skipped] += 1
          next
        end

        t = Tank.find_or_initialize_by(serial_no: key)
        was_new = t.new_record?

        assign_tank_fields(t, row)

        # 車両割当（ナンバーで解決、空文字なら未搭載に）
        if row.key?("vehicle_number_plate")
          np = (row["vehicle_number_plate"] || "").to_s.strip
          if np.empty?
            if t.vehicle_id.present?
              t.vehicle = nil
              @links += 1
            end
          else
            if (v = Vehicle.find_by(number_plate: np)) && t.vehicle_id != v.id
              t.vehicle = v
              @links += 1
            end
          end
        end

        if t.changed?
          t.save!
          was_new ? @t_stats[:created] += 1 : @t_stats[:updated] += 1
        else
          @t_stats[:skipped] += 1
        end
      end
    end

    def assign_tank_fields(t, row)
      t.maker               = val(row, "maker")
      t.first_registered_on = parse_date(val(row, "first_registered_on")) || t.first_registered_on
      t.material_detail     = val(row, "material_detail")
      t.lining              = val(row, "lining")
      t.compartments        = to_i_or_nil(val(row, "compartments"))
      t.pressure_rating     = val(row, "pressure_rating")
      t.valves              = val(row, "valves")
      t.capacity_l          = to_i_or_nil(val(row, "capacity_l"))
      t.curb_weight_kg      = to_i_or_nil(val(row, "curb_weight_kg"))
      t.current_cargo       = val(row, "current_cargo")
      t.current_shipper     = val(row, "current_shipper")
      t.depot_name          = val(row, "depot_name")
      t.manager_name        = val(row, "manager_name")
      t.manager_contact     = val(row, "manager_contact")
      t.cover_image_url     = val(row, "cover_image_url")
      t.note                = (val(row, "note") || t.note).to_s
    end

    # ---------- CSV fallback（Vehiclesのみ） ----------
    def import_csv_as_vehicles(path)
      csv = CSV.read(path, headers: true, encoding: "bom|utf-8")
      headers = norm_headers(csv.headers)
      csv.each do |row0|
        row = row_hash(headers, row0.fields)
        next if blank_row?(row)

        key = val(row, "number_plate")
        unless key
          @v_stats[:skipped] += 1
          next
        end

        v = Vehicle.find_or_initialize_by(number_plate: key)
        was_new = v.new_record?

        assign_vehicle_fields(v, row)

        if v.changed?
          v.save!
          was_new ? @v_stats[:created] += 1 : @v_stats[:updated] += 1
        else
          @v_stats[:skipped] += 1
        end
      end
    end

    # ---------- helpers ----------
    def ensure_local_path(file_param)
      return file_param.path if file_param.respond_to?(:path)
      if file_param.is_a?(String) && File.file?(file_param)
        return file_param
      end
      io = file_param.respond_to?(:read) ? file_param : nil
      raise Error, "ファイルを読み込めません" unless io
      tmp = Rails.root.join("tmp", "import_#{Time.now.to_i}_#{SecureRandom.hex(4)}")
      File.binwrite(tmp, io.read)
      tmp.to_s
    end

    def find_sheet(book, candidates)
      candidates.each { |name| return book.sheet(name) if book.sheets.include?(name) }
      nil
    end

    def norm_headers(headers)
      Array(headers).map { |h| h.to_s.strip.downcase }
    end

    def row_hash(headers, values)
      Hash[headers.zip(Array(values).map { |v| v.is_a?(String) ? v.strip : v })]
    end

    def val(row, key)
      s = row[key.to_s]
      return nil if s.nil?
      s = s.to_s.strip
      s == "" ? nil : s
    end

    def parse_date(x)
      return x if x.is_a?(Date)
      return nil if x.nil? || x.to_s.strip.empty?
      Date.parse(x.to_s) rescue nil
    end

    def to_i_or_nil(x)
      s = x.to_s.strip
      s == "" ? nil : s.to_i
    end
  end
end

