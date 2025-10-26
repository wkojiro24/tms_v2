module FleetPairsHelper
  def ym(date)
    return "" unless date
    "#{date.year}年#{date.month}月"
  end

  def ja_age(from_date, to_date = Date.current)
    return "" unless from_date
    months = (to_date.year * 12 + to_date.month) - (from_date.year * 12 + from_date.month)
    "#{months / 12}年#{months % 12}ヶ月"
  end
end
