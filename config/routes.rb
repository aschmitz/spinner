Rails.application.routes.draw do
  devise_for :users
  root to: "home#index"
  
  get '/ping' => 'home#ping'
  get '/home/nowplaying' => 'home#nowplaying'
  get '/home/queue' => 'home#queue'
  
  get '/search' => 'browse#search'
  get '/artist' => 'browse#artist'
  get '/album' => 'browse#album'
  post '/queue' => 'browse#queue'
  
  resources :library_track
  resources :queue_entry
end
