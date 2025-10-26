class FleetPairsController < ApplicationController
  def index
    # 現在搭載中（removed_on: nil）の組み合わせのみを一覧
    @mountings = Mounting
                   .where(removed_on: nil)
                   .includes(:vehicle, :tank)
                   .order("vehicles.depot_name ASC NULLS LAST, vehicles.number_plate ASC, mountings.mounted_on DESC")
  end
end
