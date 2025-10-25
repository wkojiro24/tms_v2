# app/controllers/imports_controller.rb
# frozen_string_literal: true
class ImportsController < ApplicationController
  KIND_REGISTRY = {
    "payroll"  => "Imports::PayrollImporter",
    "vehicles" => "Imports::VehicleImporter",
  }.freeze

  def new
    @form = ImportForm.new
  end

  def create
    kind  = (params[:kind].presence || "payroll")
    @form = ImportForm.new(file: params[:file], kind: kind, save: params[:save])

    unless @form.valid?
      flash.now[:alert] = @form.errors.full_messages.join(" / ")
      return render :new, status: :unprocessable_entity
    end

    klass_name = KIND_REGISTRY[kind]
    unless klass_name
      flash.now[:alert] = "未対応の種別です：#{kind}"
      @result = { ok: false, errors: [flash.now[:alert]] }
      return render :new, status: :unprocessable_entity
    end

    importer = klass_name.constantize.new

    case kind
    when "payroll"
      @result = importer.parse(@form.file)
      if @form.save == "1" && @result[:ok]
        importer.persist(@result, @form.file)
        flash.now[:notice] = "期間・社員・項目を保存しました。"
      end
    when "vehicles"
      vr = importer.import(@form.file)
      @result = { ok: true, meta: { kind: "vehicles" } }
      flash.now[:notice] = "車両インポート：新規#{vr[:created]}件／更新#{vr[:updated]}件／スキップ#{vr[:skipped]}件"
    end

    render :new
  rescue => e
    @result ||= { ok: false, errors: [e.message] }
    flash.now[:alert] = "取込失敗：#{e.message}"
    render :new, status: :internal_server_error
  end
end
