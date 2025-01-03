require 'rspotify/oauth'

# Silence the GET request warning
OmniAuth.config.silence_get_warning = true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], 
    scope: 'user-read-email playlist-modify-public playlist-modify-private user-library-read playlist-read-private playlist-read-collaborative',
    redirect_uri: 'http://localhost:3000/auth/spotify/callback'
end

OmniAuth.config.allowed_request_methods = [:post]