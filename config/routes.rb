Rails.application.routes.draw do
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
end
