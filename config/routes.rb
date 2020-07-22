Rails.application.routes.draw do
  resources :students do
    resources :lessons
  end
  post 'auth/login', to: 'authentication#authenticate'
  post 'auth/request', to:'authentication#get_authorization'
  post 'signup', to: 'users#create'
  get 'user', to: 'users#show'
  put 'user', to: 'users#update'
  delete 'user', to: 'users#destroy'
  get 'instruments', to: 'students#all_instruments'
end
