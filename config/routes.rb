Rails.application.routes.draw do
  resources :courses
  resources :users
  resources :tours
  root "articles#index"
  get "/articles", to: "articles#index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
