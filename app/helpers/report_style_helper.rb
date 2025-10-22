module ReportStyleHelper
  # —— グループ境界（太線）——
  # 「基本給」の“上に”太線、「振込支給額」の“下に”太線
  GROUP_TOP_BEFORE   = ["基本給"].freeze
  GROUP_BOTTOM_AFTER = ["振込支給額"].freeze

  # —— 行全体を強調（太字＋水色背景）——
  HILIGHT_TOTALS = ["課税支給合計", "差引支給合計"].freeze

  # 行（<tr>）に付けるクラスを決める
  def row_class_for_item(name)
    klass = []
    klass << "grp-top"    if GROUP_TOP_BEFORE.include?(name)
    klass << "grp-bottom" if GROUP_BOTTOM_AFTER.include?(name)
    klass << "total-row"  if HILIGHT_TOTALS.include?(name)
    klass.join(" ")
  end
end