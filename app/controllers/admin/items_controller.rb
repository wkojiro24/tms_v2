# app/controllers/admin/items_controller.rb
class Admin::ItemsController < ApplicationController
  def index
    @items = Item.ordered
  end

  # params[:order] = [{id:"1", position:"1"}, ...]
  def sort
    ActiveRecord::Base.transaction do
      params.require(:order).each do |h|
        Item.where(id: h[:id]).update_all(position: h[:position])
      end
    end
    redirect_to admin_items_path, notice: "並び順を保存しました。"
  end
end
