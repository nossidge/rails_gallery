class GalleriesController < ApplicationController
  before_action :set_gallery, only: [:show, :edit, :update, :destroy]
  before_action :owner_only, only: [:edit, :update, :destroy]
  before_action :logged_in_only, only: [:new, :create]

  # GET /galleries
  def index
    @galleries = Gallery.all
  end

  # GET /galleries/1
  def show
    @owner = owner?
  end

  # GET /galleries/new
  def new
    @gallery = Gallery.new
  end

  # POST /galleries
  def create
    @gallery = Gallery.new(gallery_params)
    @gallery.user = current_user

    if @gallery.save
      redirect_to edit_gallery_path(@gallery)
    else
      render 'new'
    end
  end

  # GET /galleries/1/edit
  def edit
    # If arriving from 'ImagesController#create'
    @image_errors = session[:image_errors]
    session[:image_errors] = nil

    # This is the view where the images are uploaded
    @image = Image.new
  end

  # PATCH/PUT /galleries/1
  def update
    if @gallery.update(gallery_params)
      flash[:collapse_toggle] = nil
      redirect_to edit_gallery_path(@gallery)
    else
      flash[:collapse_toggle] = 'show'
      render 'edit'
    end
  end

  # DELETE /galleries/1
  def destroy
    @gallery.destroy

    redirect_to galleries_path
  end

  private

  # Use callbacks to share common setup or constraints between actions
  def set_gallery
    @gallery = Gallery.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the whitelist through
  def gallery_params
    params.require(:gallery).permit(:name, :description)
  end

  # Is the logged-in user the owner of this record?
  def owner?
    @gallery.user == current_user
  end

  # Redirect an action if not performed by the owner
  def owner_only
    return if owner?

    # If they are logged in (but as the wrong user)
    if current_user
      flash[:alert] = 'Users can only amend their own galleries'
      redirect_to home_url

    # If they are not logged in
    else
      flash[:alert] = 'To amend gallery details, please log in'
      redirect_to login_url
    end
  end

  # Redirect an action if the current use is not logged in
  def logged_in_only
    return if current_user

    flash[:alert] = 'To create a gallery, please log in'
    redirect_to login_url
  end
end
