class SongsController < ApplicationController
  before_action :authenticate_user!

  def new
    # Convert the date parameter to a Date object if it's a string
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
  rescue Date::Error
    # Handle invalid date format
    @date = Date.current
  end

  def search
    if params[:query].present?
      @tracks = RSpotify::Track.search(params[:query])
    end
    
    respond_to do |format|
      format.turbo_stream
      format.html { render partial: 'search_results', locals: { tracks: @tracks } }
    end
  end

  def create
    @song_entry = current_user.song_entries.build(song_entry_params)

    if @song_entry.save
      redirect_to root_path, notice: 'Song added successfully!'
    else
      redirect_to new_song_path(date: params[:date]), alert: 'Failed to add song.'
    end
  end

  private

  def song_entry_params
    params.permit(:date, :song_id, :song_name, :artist_name, :album_cover_url)
  end
end