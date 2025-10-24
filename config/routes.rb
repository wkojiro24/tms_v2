Rails.application.routes.draw do
  resources :vehicles
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  root "imports#new"
  resources :imports, only: [:new, :create]  # ← まずはこの2つだけ

  # 閲覧用（GET だけ /payrolls）
  resources :payrolls, only: [:index]


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :admin do
    resources :items, only: [:index] do
      collection { patch :sort }  # 並びの一括保存
    end
  end
  namespace :reports do
    resources :months, only: [:index, :show]
    resources :employees, only: [:index, :show]
  end

end
