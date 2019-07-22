# Code cribbed from:
#   https://medium.com/@wintermeyer/authentication-from-scratch-with-rails-5-2-92d8676f6836
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to home_url, notice: "Logged in! Welcome back #{user.username}!"
    else
      flash.now[:alert] = 'Username or password is invalid'
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to home_url, notice: 'Logged out! See you later :-)'
  end
end
