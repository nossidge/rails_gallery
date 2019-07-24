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
end
