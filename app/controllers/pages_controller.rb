# frozen_string_literal: true

class PagesController < ApplicationController

  # GET /me
  # If a user is logged in, take them to their own user page.
  def me
    if current_user
      @user = current_user
      render 'users/show', id: current_user.id
    else
      redirect_to login_url
    end
  end
end
