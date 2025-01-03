class SongEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_song_entry, only: [:edit, :update, :destroy]

  def edit
    @date = @song_entry.date
    render 'songs/new' # We'll reuse the new song view for editing
  end

  def update
    if @song_entry.update(song_entry_params)
      redirect_to root_path, notice: 'Song updated successfully!'
    else
      redirect_to edit_song_entry_path(@song_entry), alert: 'Failed to update song.'
    end
  end

  def destroy
    @song_entry.destroy
    redirect_to root_path, notice: 'Song removed successfully!'
  end

  private

  def set_song_entry
    @song_entry = current_user.song_entries.find(params[:id])
  end

  def song_entry_params
    params.permit(:date, :song_id, :song_name, :artist_name, :album_cover_url)
  end
end