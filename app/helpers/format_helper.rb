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

    raw_s = cell.raw.to_s

    # 0) Excelの時刻（1900/1899系のダミー日付）→ 常に hh:mm 表示
    if raw_s.match?(/\A18\d{2}-\d{2}-\d{2}T|19\d{2}-\d{2}-\d{2}T/)
        begin
        t = Time.parse(raw_s)
        midnight = Time.new(t.year, t.month, t.day, 0, 0, 0, t.utc_offset)
        hours = (t - midnight) / 3600.0
        return fmt_hours(hours)
        rescue
        # だめなら後段へ
        end
    end

    # 1) 「時間」を含む項目名は時間として優先表示
    if item_name.include?("時間")
        # 1-1) amount が巨大（例: 秒）なら時間へ換算
        if cell.amount && cell.amount.to_f > 1000
        return fmt_hours(cell.amount.to_f / 3600.0)
        end
        # 1-2) ふつうは時間数として解釈
        return fmt_hours(cell.amount) if cell.amount
    end

    # 2) 数値があるなら数値フォーマット（整数は.00を付けない）
    return fmt_number(cell.amount) if cell.amount

    # 3) raw が純粋な数値文字列なら数値フォーマット
    if raw_s.match?(/\A-?\d+(?:\.\d+)?\z/)
        return fmt_number(raw_s.to_f)
    end

    # 4) それ以外は文字列のまま
    raw_s
    end
end
