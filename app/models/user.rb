class User < ApplicationRecord
  has_many :song_entries, dependent: :destroy
  after_create :create_or_find_playlist

  def self.from_omniauth(auth)
    user = find_or_initialize_by(spotify_id: auth.uid)
    is_new_user = user.new_record?

    user.update(
      email: auth.info.email,
      display_name: auth.info.name,
      spotify_access_token: auth.credentials.token,
      spotify_refresh_token: auth.credentials.refresh_token
    )

    # Add debug logging
    Rails.logger.debug "User saved. Playlist ID: #{user.playlist_id}"
    Rails.logger.debug "Creating playlist for user..."

    # Create playlist for both new users and existing users without playlists
    if user.playlist_id.blank?
      Rails.logger.debug "No playlist found. Creating new playlist..."
      user.create_or_find_playlist
    end

    user
  end

  def to_spotify_user
    @spotify_user ||= RSpotify::User.new({
      'id' => spotify_id,
      'credentials' => {
        'token' => spotify_access_token,
        'refresh_token' => spotify_refresh_token
      }
    })
    @spotify_user
  end

  def create_or_find_playlist
    Rails.logger.debug "Starting create_or_find_playlist"
    Rails.logger.debug "Current playlist_id: #{playlist_id}"

    return if playlist_id.present?
    
    begin
      spotify_user = self.to_spotify_user  # Add 'self.' here
      Rails.logger.debug "Spotify user initialized with ID: #{spotify_user.id}"
      
      playlist_name = "My Song Calendar #{Date.current.year}"
      Rails.logger.debug "Attempting to create playlist: #{playlist_name}"
      
      playlist = spotify_user.create_playlist!(playlist_name)
      Rails.logger.debug "Playlist created successfully with ID: #{playlist.id}"
      
      success = update(playlist_id: playlist.id)
      Rails.logger.debug "Playlist ID save status: #{success}"

    rescue => e
      Rails.logger.error "Failed to create playlist: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end

  def calendar_playlist
    return unless playlist_id
    @calendar_playlist ||= RSpotify::Playlist.find(spotify_id, playlist_id)
  end
end