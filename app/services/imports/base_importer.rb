# app/services/imports/base_importer.rb
# frozen_string_literal: true

require "roo"
module Imports
  class BaseImporter
    private
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
    def open_first_sheet(uploaded)
      x = open_spreadsheet(uploaded)
      [ x.sheet(0), x.sheet(0).row(1).map(&:to_s) ]
    end
    def row_values(sheet, row_idx)
      last_col = sheet.last_column || 100
      (2..last_col).map { |c| sheet.cell(row_idx, c) }
    end
    def numeric?(v)
      Float(v) != nil rescue false
    end
    def pick(row_hash, header_aliases)
      header_aliases.find { |h| row_hash.key?(h) }.then { |key| key ? row_hash[key] : nil }
    end
    def to_i_or_nil(v)
      i = v.to_i
      i.zero? && v.to_s !~ /\A0+\z/ ? nil : i
    end
  end
end
