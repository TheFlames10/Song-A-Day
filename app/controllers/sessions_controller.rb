class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def spotify
    redirect_to '/auth/spotify'
  end

  def create
    auth = request.env['omniauth.auth']
    user = User.from_omniauth(auth)
    if user.persisted?
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Logged in successfully!'
    else
      redirect_to root_path, alert: 'Authentication failed'
    end
  rescue StandardError => e
    redirect_to root_path, alert: 'Authentication error occurred'
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Logged out successfully!'
  end
end