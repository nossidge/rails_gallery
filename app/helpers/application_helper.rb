module ApplicationHelper
  ##
  # Get the URL for a thumbnail variant of an {ActiveStorage} image.
  # Use `#processed` to memoise the thumbnail generation.
  #
  # @param [ActiveStorage::Attached::One] image_attachment
  #   The ActiveStorage image file
  # @return [String]
  #   The URL for the thumbnail variant
  #
  def url_for_thumbnail(image_attachment)
    url_for image_attachment.variant(resize: '225x225').processed
  end

  ##
  # Render the thumbnail of the image.
  # If the image does not exist, render the default image.
  #
  # @param [Image] image
  #
  def display_thumbnail(image)
    if image
      render partial: 'images/thumbnail_img', locals: { image: image }
    else
      render partial: 'images/default_svg'
    end
  end
end
