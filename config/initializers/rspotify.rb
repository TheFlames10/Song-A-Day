require 'rspotify/oauth'

RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])

Rails.application.config.to_prepare do
    RSpotify::User.class_eval do
      def self.new_from_auth_hash(auth_hash)
        @@users_credentials ||= {}
        super
      end
    end
  end