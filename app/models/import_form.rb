# app/models/import_form.rb
class ImportForm
  include ActiveModel::Model

  # ← ActiveModel::Attributes は省略でもOK（必須ではない）
  attr_accessor :file, :kind, :save

  validates :file, presence: { message: "ファイルを選択してください" }
  validate  :content_type_check
  validates :kind, inclusion: { in: %w[payroll vehicles],
                                message: "は不正な値です（payroll / vehicles）" }

  def save?
    save.to_s == "1"
  end

  private

  def content_type_check
    return if file.blank?
    ok = %w[.xlsx .xls .csv].include?(File.extname(filename).downcase)
    errors.add(:file, "は .xlsx/.xls/.csv のみ対応です") unless ok
  end

  def filename
    file.respond_to?(:original_filename) ? file.original_filename : file.to_s
  end
end
