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
  # This should only be accessed from 'edit_gallery_path'
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

  # PATCH /images/sort
  # This should only be accessed from 'edit_gallery_path'
  # This is an AJAX request, so we don't really need to render a response.
  # But do it anyway, because it's good form.
  def sort
    image_ids = params.require(:image)

    # Make sure the 'current_user' is the owner of all passed images
    validated = image_ids.all? do |image_id|
      image = find_id(image_id)
      return bad_request('Image ID is not valid') unless image

      image.authorised?(current_user)
    end

    # Stop them if they are trying to sort images they don't own
    bad_request('Users can only amend their own images') unless validated

    # Validation passed, so update the position based on the order
    image_ids.each_with_index do |id, index|
      update_position_by_id(id, index + 1)
    end
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

  # Find an Image by id, and nullify error
  def find_id(image_id)
    Image.find(image_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  # This is in a separate method just so we can disable the cops
  # rubocop:disable Rails/SkipsModelValidations
  def update_position_by_id(image_id, value)
    Image.where(id: image_id).update_all(position: value)
  end
  # rubocop:enable Rails/SkipsModelValidations

  # Redirect an action if the current user is not authorised
  def authorised_only
    redirect_bad_actors unless @image.authorised?(current_user)
  end

  # Redirection and message to display if visitor is caught URL hacking
  def redirect_bad_actors
    if current_user  # If they are logged in (but as the wrong user)
      flash[:alert] = 'Users can only amend their own images'
      redirect_to home_url
    else             # If they are not logged in
      flash[:alert] = 'To amend image details, please log in'
      redirect_to login_url
    end
  end

  # Render a simple JSON response to a bad request
  def bad_request(msg)
    render status: :bad_request, json: { errors: msg }
  end

  # Redirect an action if the current user is not logged in
  def logged_in_only
    return if current_user

    flash[:alert] = 'To create an image, please log in'
    redirect_to login_url
  end
end
