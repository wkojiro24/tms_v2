# app/controllers/imports_controller.rb
class ImportsController < ApplicationController
  def new
    @form = ImportForm.new
  end

  def create
    @form = ImportForm.new(file: params[:file])

    if @form.valid?
      @result = sheet_parse(@form.file)  # ← 下のprivateメソッド（超シンプル）
      render :new
    else
      flash.now[:alert] = @form.errors.full_messages.join(" / ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  # 今日は“簡単の極み”：サービスを使わず、コントローラに最小実装
  # ルール：
  # - A6が数値でなければ「判別不能」
  # - 7行目=社員番号（合計/小計/計 は除外）
  # - 8行目=社員名（「○名」「合計/小計/計」除外）
  # - B9以降=項目名をユニーク抽出
  # ========= REPLACE from here =========
  def sheet_parse(uploaded)
    require "roo"

    x     = open_spreadsheet(uploaded)
    sheet = x.sheet(0)

    a6 = sheet.cell(6, 1)

    # A6 が「数値」または「YYYY年M月(度給与)」ならOK
    period = extract_period(a6)            # {year: 2025, month: 8} or nil
    ok_a6  = numeric?(a6) || period.present?

    emp_codes = row_values(sheet, 7).map { |v| v.to_s.strip } # 7行目=社員番号
    emp_names = row_values(sheet, 8)                          # 8行目=社員名

    employees = []
    emp_names.each_with_index do |name, i|
      next if skip_name?(name)
      code = emp_codes[i]
      next if skip_code?(code)
      employees << { col_index: 2 + i, code: code, name: name.to_s.strip }
    end

    # B9以降の項目（ユニーク化・空白整形）
    items = []
    r = 9
    loop do
      break if r > (sheet.last_row.to_i + 5)
      b = sheet.cell(r, 2) # B列
      row_blank = (sheet.row(r) rescue []).compact.empty?
      break if b.nil? && row_blank
      items << b.to_s.gsub(/\p{Space}+/, " ").strip if b.present?   # ← ここだけ整形あり
      r += 1
    end
    items.uniq!

    {
      ok: ok_a6,
      errors: (ok_a6 ? [] : ["A6が数値ではありません（判別不能）"]),
      meta: { a6: a6, period: period },
      employees: employees,
      items: items
    }
  end
  # ========= REPLACE to here =========

  # ========= ADD below here =========
  def extract_period(v)
    s = v.to_s.gsub(/\p{Space}/, "")  # 全/半角スペース除去
    # 例: "2025年8月度給与" / "2025年8月給与" / "2025年8月"
    if (m = s.match(/\A(?<y>\d{4})年(?<m>\d{1,2})月(?:度)?(?:給与)?\z/))
      { year: m[:y].to_i, month: m[:m].to_i }
    else
      nil
    end
  end
  # ========= ADD end =========
  
  # ---- 小さな助っ人（下は読めればOK）----
  def open_spreadsheet(uploaded)
    path = uploaded.respond_to?(:path) ? uploaded.path : uploaded
    ext  = File.extname(uploaded.respond_to?(:original_filename) ? uploaded.original_filename : uploaded.to_s).downcase
    case ext
    when ".xlsx" then Roo::Excelx.new(path)
    when ".xls"  then Roo::Excel.new(path)
    when ".csv"  then Roo::CSV.new(path, csv_options: { encoding: "UTF-8", headers: false })
    else              Roo::Spreadsheet.open(path)
    end
  end

  def row_values(sheet, row_idx)
    last_col = sheet.last_column || 100
    (2..last_col).map { |c| sheet.cell(row_idx, c) }
  end

  def numeric?(v)
    Float(v) != nil rescue false
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

