Rails.application.routes.draw do
  get "challenge_participants/create"
  get "challenge_participants/destroy"
  root "home#index"

  resource :session
  resource :registration, only: [:new, :create]
  resources :passwords, param: :token

  resources :challenges, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
  resources :checkins, only: [:new, :create, :show]
  member do
      get :invite
    end
  end

  get "join/:token", to: "challenge_participants#create", as: :join_challenge
  resources :challenge_participants, only: [:destroy]

  resources :rewards, only: [:show] do
    member do
      patch :redeem
    end
  end

  # resources :quests, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  
  get "history", to: "history#index", as: :history
  
  get "como-funciona", to: "pages#how_it_works", as: :how_it_works

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "up" => "rails/health#show", as: :rails_health_check
end

