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

    ActiveRecord::Base.transaction do
      begin
        @existing_entry = current_user.song_entries.find_by(date: @date)
        
        if @existing_entry
          if @existing_entry.update(song_attributes)
            add_song_to_playlist(params[:song_id])
            redirect_to root_path, notice: 'Song updated successfully!' and return
          end
        else
          @song_entry = current_user.song_entries.build(song_attributes)
          if @song_entry.save
            add_song_to_playlist(params[:song_id])
            redirect_to root_path, notice: 'Song added successfully!' and return
          end
        end
      rescue RSpotify::Error => e
        Rails.logger.error "Spotify API Error: #{e.message}"
        redirect_to new_song_path(date: @date), alert: 'Failed to update Spotify playlist. Please try again.' and return
      end
    end

    redirect_to new_song_path(date: @date), alert: 'Failed to save song entry.'
  end

  private

  def add_song_to_playlist(song_id)
    return unless current_user.playlist_id.present?
    
    spotify_user = RSpotify::User.new(
      'id' => current_user.spotify_id,
      'credentials' => {
        'token' => current_user.spotify_access_token,
        'refresh_token' => current_user.spotify_refresh_token
      }
    )
    
    playlist = RSpotify::Playlist.find(spotify_user.id, current_user.playlist_id)
    track = RSpotify::Track.find(song_id)
    playlist.add_tracks!([track])
  rescue => e
    Rails.logger.error "Failed to add track to playlist: #{e.message}"
    raise
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