json.extract! vehicle, :id, :name, :number_plate, :manufacturer, :model_code, :year, :mileage_km, :archived_at, :vehicle_code, :created_at, :updated_at
json.url vehicle_url(vehicle, format: :json)
