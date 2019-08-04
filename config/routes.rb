Rails.application.routes.draw do
  # For details on the DSL available within this file,
  # see http://guides.rubyonrails.org/routing.html

  root 'galleries#index', as: 'home'

  resources :users
  resources :galleries
  resources :images, except: [:edit, :update]

  resources :sessions, only: [:new, :create, :destroy]
  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'sessions', to: 'sessions#new'

  get '404', to: 'errors#not_found'
  get '422', to: 'errors#unprocessable_entity'
  get '500', to: 'errors#internal_server_error'
end
