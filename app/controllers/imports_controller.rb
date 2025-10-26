# frozen_string_literal: true

class ImportsController < ApplicationController
  KIND_REGISTRY = {
    "payroll"      => "Imports::PayrollImporter",
    "vehicles"     => "Imports::VehicleImporter",
    "vehicle_tank" => "Imports::VehicleTankImporter",
  }.freeze

  def new
    @form = ImportForm.new
  end

  def create
    kind  = (params[:kind].presence || "payroll")
    @form = ImportForm.new(file: params[:file], kind: kind, save: params[:save])

    unless @form.valid?
      flash.now[:alert] = @form.errors.full_messages.join(" / ")
      @result = { ok: false, errors: @form.errors.full_messages } # => 必ず @result を入れる
      return render :new, status: :unprocessable_entity
    end

    klass_name = KIND_REGISTRY[kind]
    unless klass_name
      msg = "未対応の種別です：#{kind}（payroll / vehicles / vehicle_tank）"
      flash.now[:alert] = msg
      @result = { ok: false, errors: [msg] }
      return render :new, status: :unprocessable_entity
    end

    importer = klass_name.constantize.new

    case kind
    when "vehicle_tank"
      begin
        vr = importer.import(@form.file.path) # Struct でも Hash でもOK
        # どんな戻り値でも画面で扱える Hash に整形
        @result = {
          ok: vr.respond_to?(:ok) ? vr.ok : !!vr[:ok],
          meta: { kind: "vehicle_tank" },
          counts: {
            processed: vr.respond_to?(:processed) ? vr.processed : (vr[:processed] || 0),
            created:   vr.respond_to?(:created)   ? vr.created   : (vr[:created]   || 0),
            updated:   vr.respond_to?(:updated)   ? vr.updated   : (vr[:updated]   || 0),
            assigned:  vr.respond_to?(:assigned)  ? vr.assigned  : (vr[:assigned]  || 0),
            skipped:   vr.respond_to?(:skipped)   ? vr.skipped   : (vr[:skipped]   || 0),
          },
          errors: (vr.respond_to?(:errors) ? vr.errors : Array(vr[:errors])),
        }

        flash.now[:notice] =
          "車両+タンク: 処理#{@result.dig(:counts, :processed)} / 新規#{@result.dig(:counts, :created)} / 更新#{@result.dig(:counts, :updated)} / 割当#{@result.dig(:counts, :assigned)} / スキップ#{@result.dig(:counts, :skipped)}"
        flash.now[:alert]  = "エラー #{@result[:errors].size} 件" if @result[:errors].present?

        return render :new
      rescue => e
        @result = { ok: false, errors: ["取込失敗：#{e.class} #{e.message}"] }
        flash.now[:alert] = @result[:errors].first
        return render :new, status: :internal_server_error
      end

    when "payroll"
      @result = importer.parse(@form.file)
      if @form.save == "1" && @result[:ok]
        importer.persist(@result, @form.file)
        flash.now[:notice] = "期間・社員・項目を保存しました。"
      end
      render :new

    when "vehicles"
      vr = importer.import(@form.file)
      @result = { ok: true, meta: { kind: "vehicles" }, counts: { created: vr[:created], updated: vr[:updated], skipped: vr[:skipped] }, errors: [] }
      flash.now[:notice] = "車両インポート：新規#{vr[:created]}件／更新#{vr[:updated]}件／スキップ#{vr[:skipped]}件"
      render :new
    end
  end
end
