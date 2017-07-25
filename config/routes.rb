Rails.application.routes.draw do
  devise_for :users
  root to: "home#index"
  
  get '/home/nowplaying' => 'home#nowplaying'
  get '/home/ping' => 'home#ping'
  post '/home/presence' => 'home#presence'
  get '/home/queue' => 'home#queue'
  
  get '/search' => 'browse#search'
  get '/artist' => 'browse#artist'
  get '/album' => 'browse#album'
  post '/queue' => 'browse#queue'
  
  resources :library_track
  resources :queue_entry
end
