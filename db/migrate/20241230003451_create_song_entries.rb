class CreateSongEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :song_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.string :song_id
      t.string :song_name
      t.string :artist_name
      t.string :album_cover_url

      t.timestamps
    end
  end
end
