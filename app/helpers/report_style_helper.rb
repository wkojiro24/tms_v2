module ReportStyleHelper
  # 行の太線・強調（従来のまま使いたければここで管理）
  GROUP_TOP_BEFORE   = ["基本給"].freeze
  GROUP_BOTTOM_AFTER = ["振込支給額"].freeze
  HILIGHT_TOTALS     = ["課税支給合計", "差引支給合計"].freeze

  def row_class_for_item(name)
    klass = []
    klass << "grp-top"    if GROUP_TOP_BEFORE.include?(name)
    klass << "grp-bottom" if GROUP_BOTTOM_AFTER.include?(name)
    klass << "total-row"  if HILIGHT_TOTALS.include?(name)
    klass.join(" ")
  end

  # ===== 区分（4つ） =====
  # 勤怠 → 賃金 → 控除 → 集計（その他は :other）
  def section_for_item(name)
    s = name.to_s

    return :summary if s.match?(/差引支給合計|支給合計|現金支給額|振込支給額|課税対象額/)
    return :deduction if s.match?(/保険|税|控除|社会保険|年金|雇用保険|住民税/)
    return :wage if s.match?(/基本給|手当|加算|報酬|調整|支給額|課税支給合計|非課税/)
    return :attendance if s.match?(/出勤|日数|就労|時間|残業|休日|代休|欠勤|深夜|早出|遅刻|早退/)

    :other
  end

  def section_title(key)
    {
      attendance: "勤怠（出勤・日数・時間）",
      wage:       "賃金（基本給・手当・加算）",
      deduction:  "控除（社会保険・税・控除）",
      summary:    "支給集計（支給合計・差引支給）",
      other:      "その他"
    }[key] || "その他"
  end
end
