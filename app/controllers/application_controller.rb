class ApplicationController < ActionController::Base
  helper_method :current_user
  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end

  # In case the user has been deleted
  rescue Module::DelegationError, ActiveRecord::RecordNotFound
    session[:user_id] = nil
    @current_user = nil
  end
end
