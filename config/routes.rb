Rails.application.routes.draw do
  root 'pages#home'
  
  get '/auth/spotify/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  post '/auth/spotify', to: lambda { |env| [404, {}, ["Not Found"]] }
  
  resources :song_entries, except: [:index, :show]
end