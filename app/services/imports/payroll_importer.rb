# app/services/imports/payroll_importer.rb
# frozen_string_literal: true

module Imports
  class PayrollImporter < BaseImporter
    def parse(uploaded)
      sheet = open_spreadsheet(uploaded).sheet(0)
      a6 = sheet.cell(6, 1)
      period = extract_period(a6)
      ok_a6  = numeric?(a6) || period.present?

      emp_codes = row_values(sheet, 7).map { |v| v.to_s.strip }
      emp_names = row_values(sheet, 8)

      employees = []
      emp_names.each_with_index do |name, i|
        next if skip_name?(name)
        code = emp_codes[i]
        next if skip_code?(code)
        employees << { col_index: 2 + i, code: code, name: name.to_s.strip }
      end

      last_row  = sheet.last_row.to_i
      basic_row = nil
      (9..(last_row + 5)).each do |rr|
        v = sheet.cell(rr, 2)
        next if v.nil?
        nm = v.to_s.gsub(/\p{Space}+/, " ").strip
        if nm == "基本給"
          basic_row = rr
          break
        end
      end

      tmp = []
      r = 9
      loop do
        break if r > (last_row + 5)
        b = sheet.cell(r, 2)
        row_blank = (sheet.row(r) rescue []).compact.empty?
        break if b.nil? && row_blank
        if b.present?
          name  = b.to_s.gsub(/\p{Space}+/, " ").strip
          above = basic_row ? (r < basic_row) : true
          tmp << { row_index: r, name: name, above_basic: above }
        end
        r += 1
      end

      items = tmp.group_by { |h| [ h[:name], h[:above_basic] ] }
                 .map { |(nm, ab), arr| { row_index: arr.first[:row_index], name: nm, above_basic: ab } }

      { ok: ok_a6,
        errors: (ok_a6 ? [] : [ "A6が数値ではありません（判別不能）" ]),
        meta: { a6: a6, period: period },
        employees: employees,
        items: items }
    end

    def persist(result, uploaded)
      pinfo = result.dig(:meta, :period)
      return unless pinfo
      per = Period.find_or_create_by!(year: pinfo[:year], month: pinfo[:month])

      emp_map = {}
      result[:employees].each do |e|
        emp = Employee.find_or_initialize_by(code: e[:code])
        emp.name = e[:name].to_s.strip if e[:name].present?
        emp.save!
        emp_map[e[:col_index]] = emp
      end

      item_map = {}
      result[:items].each do |it|
        name = it[:name].to_s.strip
        ab   = it[:above_basic]
        item = Item.find_or_create_by!(name: name, above_basic: ab)
        if item.row_index.nil? || (it[:row_index] && it[:row_index] < item.row_index)
          item.update!(row_index: it[:row_index])
        end
        item_map[it[:row_index]] = item
      end

      sheet = open_spreadsheet(uploaded).sheet(0)
      item_map.each do |row_idx, item|
        emp_map.each do |col_idx, emp|
          val = sheet.cell(row_idx, col_idx)
          next if val.nil? || (val.respond_to?(:empty?) && val.empty?)
          raw    = val.to_s
          amount = (Float(raw) rescue nil) # 勝手な補正なし
          cell = PayrollCell.find_or_initialize_by(period: per, employee: emp, item: item)
          cell.raw    = raw
          cell.amount = amount
          cell.save!
        end
      end
    end

    private
    def extract_period(v)
      s = v.to_s.gsub(/\p{Space}/, "")
      if (m = s.match(/\A(?<y>\d{4})年(?<m>\d{1,2})月(?:度)?(?:給与)?\z/))
        { year: m[:y].to_i, month: m[:m].to_i }
      end
    end
    def skip_name?(name)
      s = (name || "").to_s.gsub(/\p{Space}/, "")
      return true if s.empty?
      return true if s.match?(/\A[0-9０-９]+名\z/)
      %w[合計 小計 計].include?(s)
    end
    def skip_code?(code)
      s = (code || "").to_s.gsub(/\p{Space}/, "")
      return true if s.empty?
      %w[合計 小計 計].include?(s)
    end
  end
end
