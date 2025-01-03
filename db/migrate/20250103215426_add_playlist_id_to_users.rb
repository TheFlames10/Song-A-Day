class AddPlaylistIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :playlist_id, :string
  end
end
