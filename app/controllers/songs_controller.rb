class SongsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_existing_entry, only: [:new]

  def new
    # Convert the date parameter to a Date object if it's a string
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @editing = @existing_entry.present?
  rescue Date::Error
    # Handle invalid date format
    @date = Date.current
  end

  def search
    @date = params[:date]
    @existing_entry = current_user.song_entries.find_by(date: @date)

    if params[:query].present?
      @tracks = RSpotify::Track.search(params[:query])
    end
    
    respond_to do |format|
      format.html { render 'search', layout: false }
    end
  end

  def create
    @date = params[:date]
    song_attributes = {
      date: @date,
      song_id: params[:song_id],
      song_name: params[:song_name],
      artist_name: params[:artist_name],
      album_cover_url: params[:album_cover_url]
    }

    @existing_entry = current_user.song_entries.find_by(date: @date)
    
    ActiveRecord::Base.transaction do
      if @existing_entry
        # Remove old song from playlist
        remove_song_from_playlist(@existing_entry.song_id) if @existing_entry.song_id != song_attributes[:song_id]
        
        if @existing_entry.update(song_attributes)
          # Add new song to playlist
          add_song_to_playlist(song_attributes[:song_id])
          redirect_to root_path, notice: 'Song updated successfully!'
        else
          redirect_to new_song_path(date: @date), 
            alert: "Failed to update song: #{@existing_entry.errors.full_messages.join(', ')}"
        end
      else
        @song_entry = current_user.song_entries.build(song_attributes)
        if @song_entry.save
          # Add new song to playlist
          add_song_to_playlist(song_attributes[:song_id])
          redirect_to root_path, notice: 'Song added successfully!'
        else
          redirect_to new_song_path(date: @date), 
            alert: "Failed to add song: #{@song_entry.errors.full_messages.join(', ')}"
        end
      end
    end
  rescue => e
    Rails.logger.error "Playlist operation failed: #{e.message}"
    redirect_to new_song_path(date: @date), alert: 'Failed to update playlist'
  end

  private

  def add_song_to_playlist(song_id)
    return unless current_user.calendar_playlist
    
    track = RSpotify::Track.find(song_id)
    current_user.calendar_playlist.add_tracks!([track])
  end

  def remove_song_from_playlist(song_id)
    return unless current_user.calendar_playlist
    
    track = RSpotify::Track.find(song_id)
    current_user.calendar_playlist.remove_tracks!([track])
  end

  def song_entry_params
    params.permit(:date, :song_id, :song_name, :artist_name, :album_cover_url)
  end

  def set_existing_entry
    @existing_entry = current_user.song_entries.find_by(date: params[:date])
  end
end