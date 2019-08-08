# frozen_string_literal: true

class ImagesController < ApplicationController
  before_action :set_image, only: %i[show destroy]
  before_action :authorised_only, only: %i[destroy]
  before_action :logged_in_only, only: %i[new create]

  # GET /images
  def index
    @images = Image.all
  end

  # GET /images/1
  def show; end

  # GET /images/new
  def new
    @image = Image.new
  end

  # POST /images
  # But, this should only be accessed from 'edit_gallery_path'
  def create
    @gallery = Gallery.find(params[:image][:gallery_id])
    @image = @gallery.images.create(image_params)

    unless @image.save
      # TODO: This seems a bit hacky, but it works.
      # Save the errors to the session.
      # Remember to set 'session[:image_errors] = nil'
      #   in the destination controller, or it will last forever...
      session[:image_errors] = @image.errors.full_messages
    end

    redirect_to edit_gallery_path(@gallery)
  end

  # DELETE /images/1
  def destroy
    gallery = @image.gallery
    @image.file.purge
    @image.destroy

    redirect_to gallery_path(gallery)
  end

  private

  # Set the image based on the parameters sent
  def set_image
    @image = Image.find(params[:id])
  end

  # Allow only parameters from the whitelist
  def image_params
    params.require(:image).permit(:file)
  end

  # Redirect an action if the current user is not authorised
  def authorised_only
    return if @image.authorised?(current_user)

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

  # Redirect an action if the current user is not logged in
  def logged_in_only
    return if current_user

    flash[:alert] = 'To create an image, please log in'
    redirect_to login_url
  end
end
