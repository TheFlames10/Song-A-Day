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
    @existing_entry = current_user.song_entries.find_by(date: @date)

    song_attributes = {
      song_id: params[:song_id],
      song_name: params[:song_name],
      artist_name: params[:artist_name],
      album_cover_url: params[:album_cover_url],
      date: @date
    }

    @song_entry = current_user.song_entries.find_or_initialize_by(date: @date)

    # Debugging
    Rails.logger.debug "Existing Entry: #{@existing_entry.inspect}"
    Rails.logger.debug "Song Attributes: #{song_attributes.inspect}"
    
    if @song_entry.update(song_attributes)
      redirect_to root_path, notice: 'Song updated successfully!'
    else
      redirect_to new_song_path(date: @date), 
        alert: "Failed to update song: #{@song_entry.errors.full_messages.join(', ')}"
    end
  end

  private

  def song_entry_params
    params.permit(:date, :song_id, :song_name, :artist_name, :album_cover_url)
  end

  def set_existing_entry
    @existing_entry = current_user.song_entries.find_by(date: params[:date])
  end
end