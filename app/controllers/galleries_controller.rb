class GalleriesController < ApplicationController
  before_action :set_gallery, only: [:show, :edit, :update, :destroy]

  # GET /galleries
  def index
    @galleries = Gallery.all
  end

  # GET /galleries/1
  def show
  end

  # GET /galleries/new
  def new
    @gallery = Gallery.new
  end

  # POST /galleries
  def create
    @gallery = Gallery.new(gallery_params)

    if @gallery.save
      redirect_to @gallery
    else
      render 'new'
    end
  end

  # GET /galleries/1/edit
  def edit
  end

  # PATCH/PUT /galleries/1
  def update
    if @gallery.update(gallery_params)
      redirect_to @gallery
    else
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
end
