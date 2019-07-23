class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]
  before_action :owner_only, only: [:edit, :update, :destroy]
  before_action :logged_in_only, only: [:new, :create]

  # GET /images
  def index
    # TODO: Is this necessary?
    @images = Image.all
  end

  # GET /images/1
  def show
    @owner = owner?
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # POST /images
  # But, this should only be accessed from 'edit_gallery_path'
  def create
    @gallery = Gallery.find(params[:image][:gallery_id])
    @image = @gallery.images.create(image_params)

    if @image.save
      redirect_to edit_gallery_path(@gallery)
    else
      puts '########################################'
      #render 'new'
    end
  end

  # GET /images/1/edit
  def edit
  end

  # PATCH/PUT /images/1
  def update
    # TODO: Is this necessary?
    if @image.update(image_params)
      redirect_to @image
    else
      render 'edit'
    end
  end

  # DELETE /images/1
  def destroy
    @image.destroy

    redirect_to images_path
  end

  private

  # Use callbacks to share common setup or constraints between actions
  def set_image
    @image = Image.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the whitelist through
  def image_params
    params.require(:image).permit(:file)
  end

  # Is the logged-in user the owner of this record?
  def owner?
    @image.gallery.user == current_user
  end

  # Redirect an action if not performed by the owner
  def owner_only
    return if owner?

    # If they are logged in (but as the wrong user)
    if current_user
      flash[:alert] = 'Users can only amend their own images'
      redirect_to home_url

    # If they are not logged in
    else
      flash[:alert] = 'To amend image details, please log in'
      redirect_to login_url
    end
  end

  # Redirect an action if the current use is not logged in
  def logged_in_only
    return if current_user

    flash[:alert] = 'To create an image, please log in'
    redirect_to login_url
  end
end
