class AuthController < ApplicationController
  def login
    redirect_to root_path if current_user
  end
end