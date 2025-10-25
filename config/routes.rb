Rails.application.routes.draw do
  root "dashboard#home"   # トップはこれ1つに固定

  resources :vehicles, only: [ :index, :new, :create, :show ]
  resources :tanks,    only: [ :index, :new, :create, :show ]
  resources :purchase_records, only: [ :index, :new, :create ]
  resources :imports,  only: [ :new, :create ]
  resources :payrolls, only: [ :index ]

  get "up"               => "rails/health#show",        as: :rails_health_check
  get "service-worker"   => "rails/pwa#service_worker",  as: :pwa_service_worker
  get "manifest"         => "rails/pwa#manifest",        as: :pwa_manifest

  namespace :admin do
    resources :items, only: [ :index ] do
      collection { patch :sort }
    end
  end
  namespace :reports do
    resources :months,    only: [ :index, :show ]
    resources :employees, only: [ :index, :show ]
  end
end
