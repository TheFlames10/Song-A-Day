Rails.application.routes.draw do
  root 'pages#home'

  # Auth routes
  get '/login', to: 'auth#login', as: :login  
  get '/auth/spotify/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  post '/auth/spotify', to: lambda { |env| [404, {}, ["Not Found"]] }

  # Song selection routes
  get '/songs/new', to: 'songs#new', as: :new_song
  get '/songs/search', to: 'songs#search', as: :search_songs
  post '/songs/create', to: 'songs#create', as: :create_song
  
  resources :song_entries, except: [:index, :show]
end