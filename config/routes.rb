Rails.application.routes.draw do
  devise_for :users
  root to: "home#index"
  mount ActionCable.server => '/cable'
  
  get '/home/nowplaying' => 'home#nowplaying'
  get '/home/ping' => 'home#ping'
  post '/home/presence' => 'home#presence'
  get '/home/queue' => 'home#queue'
  get '/home/recent' => 'home#recent'
  post '/home/skip_my_song' => 'home#skip_my_song'
  
  get '/search' => 'browse#search'
  get '/artist' => 'browse#artist'
  get '/album' => 'browse#album'
  
  resources :library_track
  resources :queue_entry
end
