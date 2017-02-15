Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root   :to => "users#me"
  get    'login', to: 'sessions#new'
  post   'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Callback route for using JWT with this app
  get    'callback', to:'sessions#callback', as: :callback

  # about-related routes
  scope '/about' do
    get    '/jwt/download_key', to: 'about#download_jwt_key', as: :download_jwt_key
  end

  # Logging in or signing up
  get    'signup', to: 'sessions#signup', as: :signup
  post   'register', to: 'sessions#register', as: :register

  # omniauth routes
  get    'auth/:provider/callback' => 'sessions#omniauth_callback'
  get    '/auth/failure' => 'sessions#failure'

  # User-related routes
  get 'users/me', to: 'users#me', as: :me
  post 'users/add_api_key', to: 'users#add_api_key', as: :add_api_key
  resources :users, only: [:show, :index]

  # Organization-related routes
  get 'organizations/mine', to: 'organizations#mine', as: :my_organizations
  resources :organizations, constraints: { id: /[a-z0-9_]+/ }
end
