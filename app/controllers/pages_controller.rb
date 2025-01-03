class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    @current_month = Date.current
    # Preload all song entries for the month in a single query
    @song_entries = current_user.song_entries
                              .where(date: @current_month.beginning_of_month..@current_month.end_of_month)
                              .index_by(&:date)
  end
end