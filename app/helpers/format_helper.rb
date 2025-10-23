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

  # cell と item から最適表示を決める
  # - item名に「時間」が含まれる → 時間として表示（amountがあればそれを時間数として扱う）
  # - raw が "1900-01-01T..." 形式 → Excelの時間とみなして hours に変換
  def display_cell(cell, item_name:)
    return "" unless cell

    name  = item_name.to_s
    raw   = cell.raw
    raw_s = raw.to_s.strip
    num   = cell.amount # 数値で保存されていればここに入っている（nil可）

    # 1) Excelダミー日付（1899/1900…）→ hh:mm に統一
    #    例: 1899-12-31 21:00, 1899-12-31T21:00:00+00:00, 1900-01-01T8:00Z
    if raw_s.match?(/\A(18|19)\d{2}-\d{2}-\d{2}(?:[ T]\d{1,2}:\d{2}(?::\d{2})?)?(?:Z|[+-]\d{2}:\d{2})?\z/)
      begin
        t = Time.parse(raw_s)
        midnight = Time.new(t.year, t.month, t.day, 0, 0, 0, t.utc_offset)
        hours = (t - midnight) / 3600.0
        return fmt_hours(hours)
      rescue
        # 後段へフォールバック
      end
    end

    # 2) この項目が「時間系」か？
    #    平日残業/所定外/法定外/休出/深夜/早出/遅刻/早退 などを時間扱い
    time_like = name.match?(/時間|残業|所定外|法定外|休出|深夜|早出|遅刻|早退/)

    if time_like
      # 2-1) "hh:mm(:ss)" の文字列はそのまま（表示は統一でOK）
      return raw_s if raw_s.match?(/\A\d{1,2}:\d{2}(?::\d{2})?\z/)

      if num
        # 2-2) 1000超は秒とみなして h へ
        return fmt_hours(num.to_f / 3600.0) if num.to_f > 1000
        # 2-3) 0〜1 の小数は Excel の時刻（1 日 = 1.0）とみなす
        return fmt_hours(num.to_f * 24.0) if num.to_f >= 0 && num.to_f <= 1
        # 2-4) それ以外は「時間数（小数）」とみなす
        return fmt_hours(num.to_f)
      end
    end

    # 3) ここまでで時間として出せなければ、数値は通常フォーマット
    return fmt_number(num) if num

    # 4) 数字文字列は整形
    return fmt_number(raw_s.to_f) if raw_s.match?(/\A-?\d+(?:\.\d+)?\z/)

    # 5) 文字列のまま
    raw_s
  end



end
