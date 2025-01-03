class SongEntry < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :song_name, presence: true
  validates :artist_name, presence: true
  validates :album_cover_url, presence: true
  # validates :date, uniqueness: { scope: :user_id, message: "already has a song entry" }
end
