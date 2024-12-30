class SongEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_song_entry, only: [:edit, :update, :destroy]

  def create
    @song_entry = current_user.song_entries.build(song_entry_params)
    if @song_entry.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to root_path }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def song_entry_params
    params.require(:song_entry).permit(:date, :song_id, :song_name, :artist_name, :album_cover_url)
  end

  def set_song_entry
    @song_entry = current_user.song_entries.find(params[:id])
  end
end