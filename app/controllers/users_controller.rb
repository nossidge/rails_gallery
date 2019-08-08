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
  # We are updating specific fields in this action.
  # The '#update_attribute' method will update only one field, but it
  # will not perform any validation at all.
  # In order to do this, we only need to validate the necessary field, not the
  # whole object (because most fields will not be passed, they will evaluate
  # to blank, and that will trip their 'validates uniqueness' validation.)
  # So we need to perform the field validation ourselves and only save
  # the value to the database if it passes.
  def update
    param_hash = user_params.dup

    # Validate each parameter individually
    @user.validate_params!(param_hash)

    # If there are errors, cancel the update and tell the user
    return if param_errors(param_hash)

    # From this point on, all validation has passed
    param_hash.each do |field, value|
      update_field!(field, value)
    end
    fields_list = param_hash.keys.map(&:titlecase).to_sentence
    flash[:notice] = "#{fields_list} updated"

    redirect_to edit_user_path(@user)
  end

  # DELETE /users/1
  def destroy
    @user.destroy

    redirect_to users_path
  end

  private

  # If there are errors, cancel the update and tell the user
  def param_errors(param_hash)
    return false unless @user.errors.any?

    param_hash.keys.each do |field|
      flash.now["collapse_toggle_#{field}"] = 'show'
    end
    render 'edit'
    true
  end

  # Save a value to the user's field.
  # Note: Make sure all validation has passed first!
  #
  # rubocop:disable Rails/SkipsModelValidations
  def update_field!(field, value)
    @user.update_attribute(field, value)
  end
  # rubocop:enable Rails/SkipsModelValidations

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
