class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    @current_month = Date.current
    @song_entries = current_user.song_entries.where(date: @current_month.all_month)
  end
end