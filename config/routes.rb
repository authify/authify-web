Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get    'login', to: 'sessions#new'
  post   'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get    'callback', to:'sessions#callback', as: :callback

  get 'users/me', to: 'users#me', as: :me
  resources :users, only: [:show, :index]

  get    'test', to: 'tests#index'
end
