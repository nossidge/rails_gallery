# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :authorised_only, only: %i[edit update destroy]
  before_action :already_logged_in, only: %i[new create]

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to @user
    else
      render 'new'
    end
  end

  # GET /users/1/edit
  def edit; end

  # PATCH/PUT /users/1
  def update
    param_hash = params['user'].dup
    password_confirmation = param_hash.delete('password_confirmation')

    # We are updating specific fields in this action.
    # In order to do this, we only need to validate the necessary field,
    # not the whole object (because most fields will be blank.)
    # The '#update_attribute' method will update only one field, but it
    # will not perform any validation at all.
    # So we need to perform the field validation ourselves and only save
    # the value to the database if it passes.
    if param_hash['username']
      @user.validate_field(:username, param_hash['username'])

    elsif param_hash['email']
      @user.validate_field(:email, param_hash['email'])

    elsif param_hash['password']
      @user.validate_field(:password, param_hash['password'])

      # Manually add this simple comparison check.
      if param_hash['password'] != password_confirmation
        msg = "doesn't match Password"
        @user.errors.messages[:password_confirmation] << msg
      end
    end

    if @user.errors.any?
      param_hash.keys.each do |field|
        flash.now["collapse_toggle_#{field}"] = 'show'
      end
      render 'edit'
      return
    end

    # rubocop:disable Rails/SkipsModelValidations
    # All validation has passed, so save to database.
    param_hash.each do |field, value|
      @user.update_attribute(field, value)
      flash[:notice] = "#{field.titlecase} updated"
    end
    # rubocop:enable Rails/SkipsModelValidations

    redirect_to edit_user_path(@user)
  end

  # DELETE /users/1
  def destroy
    @user.destroy

    redirect_to users_path
  end

  private

  # Set the user based on the parameters sent
  def set_user
    @user = User.find(params[:id])
  end

  # Allow only parameters from the whitelist
  def user_params
    whitelist = %i[username email password password_confirmation]
    params.require(:user).permit(*whitelist)
  end

  # Redirect an action if the current user is not authorised
  def authorised_only
    return if @user.authorised?(current_user)

    # If they are logged in (but as the wrong user)
    if current_user
      flash[:alert] = 'Users can only amend their own information'
      redirect_to home_url

    # If they are not logged in
    else
      flash[:alert] = 'To amend user details, please log in'
      redirect_to login_url
    end
  end

  # Redirect a create action if the user is already logged in
  def already_logged_in
    return unless current_user

    flash[:alert] = 'You are already logged in!'
    redirect_to user_path(current_user)
  end
end
