Rails.application.routes.draw do
  get "history/index"
  get "quests/index"
  get "quests/show"
  get "quests/new"
  get "quests/create"
  get "rewards/show"
  get "checkins/new"
  get "checkins/create"
  get "challenges/index"
  get "challenges/show"
  get "challenges/new"
  get "challenges/create"
  root "home#index"

  resource :session
  resource :registration, only: [:new, :create]
  resources :passwords, param: :token
  resources :challenges, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :checkins, only: [:new, :create]
  end

  resources :rewards, only: [:show] do
    member do
      patch :redeem
    end
  end

  resources :quests, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  
  get "history", to: "history#index", as: :history

  get "up" => "rails/health#show", as: :rails_health_check
end

