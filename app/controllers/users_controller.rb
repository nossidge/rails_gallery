class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :owner_only, only: [:edit, :update, :destroy]
  before_action :already_logged_in, only: [:new, :create]

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show
    @owner = owner?
    @gallery_count = @user.galleries.count
    @images_count = @user.galleries.inject(0) do |sum, gallery|
      sum + gallery.images.count
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user
    else
      render 'new'
    end
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user
    else
      render 'edit'
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy

    redirect_to users_path
  end

  private

  # Use callbacks to share common setup or constraints between actions
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the whitelist through
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  # Is the logged-in user the owner of this record?
  def owner?
    @user == current_user
  end

  # Redirect an action if not performed by the owner
  def owner_only
    return if owner?

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
