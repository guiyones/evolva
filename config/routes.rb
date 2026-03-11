Rails.application.routes.draw do
  get "challenges/index"
  get "challenges/show"
  get "challenges/new"
  get "challenges/create"
  root "home#index"

  resource :session
  resource :registration, only: [:new, :create]
  resources :passwords, param: :token
  resources :challenges, only: [:index, :show, :new, :create]

  get "up" => "rails/health#show", as: :rails_health_check
end

