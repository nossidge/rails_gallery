# Code cribbed from:
#   https://medium.com/@wintermeyer/authentication-from-scratch-with-rails-5-2-92d8676f6836
class SessionsController < ApplicationController
  def new
  end

  def create
    return session_invalid unless session_params_present(params)

    email = params[:email].downcase
    user = User.find_by_email(email)

    return session_invalid unless user&.authenticate(params[:password])

    session[:user_id] = user.id
    redirect_to home_url, notice: "Welcome back #{user.username}!"
  end

  def destroy
    session[:user_id] = nil
    redirect_to home_url, notice: 'Logged out! See you later :-)'
  end

  private

  def session_params_present(params)
    [:email, :password].all? do |param|
      params.has_key?(param)
    end
  end

  def session_invalid
    flash.now[:alert] = 'Email or password is invalid'
    render 'new'
  end
end
