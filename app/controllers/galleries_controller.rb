# frozen_string_literal: true

class GalleriesController < ApplicationController
  before_action :set_gallery, only: %i[show edit update destroy]
  before_action :authorised_only, only: %i[edit update destroy]
  before_action :logged_in_only, only: %i[new create]

  # GET /galleries
  def index
    @galleries = Gallery.all
  end

  # GET /galleries/1
  def show; end

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

  # Set the gallery based on the parameters sent
  def set_gallery
    @gallery = Gallery.find(params[:id])
  end

  # Allow only parameters from the whitelist
  def gallery_params
    params.require(:gallery).permit(:name, :description)
  end

  # Redirect an action if the current user is not authorised
  def authorised_only
    return if @gallery.authorised?(current_user)

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

  # Redirect an action if the current user is not logged in
  def logged_in_only
    return if current_user

    flash[:alert] = 'To create a gallery, please log in'
    redirect_to login_url
  end
end
