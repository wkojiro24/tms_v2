module FormatHelper
  # 金額や人数などの数値表示
  def fmt_number(n)
    return "" if n.nil?
    n = n.to_f
    if (n % 1).zero?
      number_with_delimiter(n.to_i)
    else
      number_with_precision(n, precision: 2, delimiter: ",")
    end
  end

  # 時間(時間数)を "hh:mm" に
  def fmt_hours(hours_f)
    return "" if hours_f.nil?
    total_minutes = (hours_f.to_f * 60).round
    h = total_minutes / 60
    m = total_minutes % 60
    format("%d:%02d", h, m)
  end


    def basic_row_index
      @basic_row_index ||= Item.find_by(name: "基本給")&.row_index
    end


    def time_like_item?(item)
      # ① 最優先で above_basic を見る（下は金額扱い）
      if item.respond_to?(:above_basic) && !item.above_basic.nil?
        return false unless item.above_basic   # false=下=金額
        name = item.name.to_s
        return true if name.include?("時間") || name.match?(/残業|深夜|早出|遅刻|早退/)
        return false
      end

      # ② 古いデータの保険（行位置ベース）
      name = item.name.to_s
      return true if name.include?("時間")
      if basic_row_index && item.row_index && item.row_index < basic_row_index
        return true if name.match?(/残業|深夜|早出|遅刻|早退/)
      end
      false
    end






    # cell と item から最適表示を決める
    # - item名に「時間」が含まれる → 時間として表示（amountがあればそれを時間数として扱う）
    # - raw が "1900-01-01T..." 形式 → Excelの時間とみなして hours に変換
    def display_cell(cell, item:)
      return "" unless cell

      raw_s = cell.raw.to_s.strip
      num   = cell.amount
      is_time = time_like_item?(item)

      # 1) 1899/1900 系のダミー日付は “時刻” として扱う
      if raw_s.match?(/\A(18|19)\d{2}-\d{2}-\d{2}(?:[ T]\d{1,2}:\d{2}(?::\d{2})?)?(?:Z|[+-]\d{2}:\d{2})?\z/)
        begin
          t = Time.parse(raw_s)
          midnight = Time.new(t.year, t.month, t.day, 0, 0, 0, t.utc_offset)
          hours = (t - midnight) / 3600.0
          return fmt_hours(hours)
        rescue
        end
      end

      if is_time
        # 2) "H:M(:S)" 文字列（"1:1" も "1:01" に丸める）
        if raw_s.match?(/\A(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?\z/)
          h = Regexp.last_match(1).to_i
          m = Regexp.last_match(2).to_i
          s = (Regexp.last_match(3) || "0").to_i
          return fmt_hours(h + m/60.0 + s/3600.0)
        end
        # 3) 整数文字列（"18"）は 18:00 とみなす
        if raw_s.match?(/\A\d+\z/)
          return fmt_hours(raw_s.to_i)
        end
        # 4) amount が秒（>1000）なら時間に
        return fmt_hours(num.to_f / 3600.0) if num && num.to_f > 1000
        # 5) Excel 小数日(0〜1未満) → 時間
        return fmt_hours(num.to_f * 24.0)   if num && num.to_f >= 0 && num.to_f < 1
        # 6) 小数時間（7.5 等）
        return fmt_hours(num.to_f)          if num
      end

      # 7) ここまで来たら金額/日数の通常表示
      return fmt_number(num) if num
      return fmt_number(raw_s.to_f) if raw_s.match?(/\A-?\d+(?:\.\d+)?\z/)
      raw_s
    end

    def anomaly_reason_item(item, cell)
      return nil unless cell
      name = item.name.to_s

      # 値を数値化（amount 優先）
      val =
        if cell.amount
          cell.amount.to_f
        elsif (s = cell.raw.to_s.strip).match?(/\A-?\d+(?:\.\d+)?\z/)
          s.to_f
        else
          nil
        end

      if time_like_item?(item)
        hours = val && val > 1000 ? (val / 3600.0) : val
        return "時間が負、または多すぎ" if hours && (hours < 0 || hours > 24*31)
      elsif name.include?("日数") || name.end_with?("日")
        return "日数が負、または31超" if val && (val < 0 || val > 31)
      elsif name.match?(/給|税|保険|報酬|合計|額|金/)
        return "金額が大きすぎる可能性" if val && val.abs > 10_000_000
      end
      nil
    end
end
