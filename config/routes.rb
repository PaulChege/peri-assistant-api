require 'sidekiq/web'

Rails.application.routes.draw do
  
  mount Sidekiq::Web => "/sidekiq" # access it at http://localhost:3000/sidekiq

  resources :students do
    post :send_payment_reminders
    resources :lessons
  end
  
  post 'auth/login', to: 'authentication#authenticate'
  post 'auth/login_google', to:'authentication#authenticate_google'
  post 'signup', to: 'users#create'
  get 'user', to: 'users#show'
  put 'user', to: 'users#update'
  delete 'user', to: 'users#destroy'
  get 'instruments', to: 'students#all_instruments'

  resources :users, only: [] do
    collection do
      get :student_institutions
      get :student_instruments
    end
  end

  resources :institutions, only: [] do
    collection do
      get :search
    end
  end

  resources :lessons, only: [] do
    collection do
      get :user_lessons
    end
  end 
end
