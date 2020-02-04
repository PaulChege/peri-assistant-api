# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :students do
    resources :lessons
  end
  resources :users, only: [:update, :destroy]
  post 'auth/login', to: 'authentication#authenticate'
  post 'signup', to: 'users#create'
  get 'instruments', to: 'students#all_instruments'
end
