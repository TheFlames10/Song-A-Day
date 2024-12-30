class User < ApplicationRecord
  has_many :song_entries, dependent: :destroy

  def self.from_omniauth(auth)
    user = find_or_initialize_by(spotify_id: auth.uid)
    user.update(
      email: auth.info.email,
      display_name: auth.info.name,
      spotify_access_token: auth.credentials.token,
      spotify_refresh_token: auth.credentials.refresh_token
    )
    user
  end

  def spotify_user
    @spotify_user ||= RSpotify::User.new(
      'id' => spotify_id,
      'credentials' => {
        'token' => spotify_access_token,
        'refresh_token' => spotify_refresh_token
      }
    )
  end
end