class PagesController < ApplicationController
  def home
    @current_month = Date.current
    @song_entries = current_user.song_entries.where(date: @current_month.all_month) if current_user
  end
end