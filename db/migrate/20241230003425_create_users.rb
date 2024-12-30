class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :spotify_id
      t.string :email
      t.string :display_name
      t.string :spotify_access_token
      t.string :spotify_refresh_token

      t.timestamps
    end
  end
end
