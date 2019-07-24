module UsersHelper
  ##
  # Get an example image from any gallery by the user.
  # This doesn't need to be the best image, just as long as there is one.
  #
  # @param [User] user
  # @return [String, nil]
  #   The URL for the thumbnail variant of the file
  #   Returns nil if the user has not yet uploaded an image
  #
  def example_image_for_user(user)
    user.galleries.each do |gallery|
      gallery.images.each do |image|
        return url_for_thumbnail(image.file)
      end
    end
    nil
  end
end
