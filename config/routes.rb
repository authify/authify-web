Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get    'login'    => 'sessions#new'
  post   'login'    => 'sessions#create'
  delete 'logout'   => 'sessions#destroy'
  get    'callback' => 'sessions#callback'

  resources :users, only: [:show, :index]

  get    'test'     => 'tests#index'
end
