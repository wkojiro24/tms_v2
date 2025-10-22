# app/models/import_form.rb
class ImportForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :file

  validates :file, presence: { message: "ファイルを選択してください" }
  validate  :content_type_check

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
