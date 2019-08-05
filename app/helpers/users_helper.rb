# frozen_string_literal: true

module UsersHelper
  ##
  # Get an example image from any gallery by the user.
  # This doesn't need to be the best image, just as long as there is one.
  #
  # @param [User] user
  # @return [Image, nil]
  #   Returns nil if the user has not yet uploaded an image
  #
  def example_image_for_user(user)
    user.galleries.each do |gallery|
      gallery.images.each do |image|
        return image
      end
    end
    nil
  end

  ##
  # Show the number of images and galleries for a user, in a human
  # readable HTML format.
  #
  # @param [User] user
  # @return [String] HTML safe output
  #
  def display_image_and_gallery_count(user)
    images_count = user.galleries.inject(0) do |sum, gallery|
      sum + gallery.images.size
    end
    gallery_count = user.galleries.size
    <<~MSG.strip.html_safe
      User has
      <strong>#{images_count}</strong> #{'image'.pluralize(images_count)}
      in
      <strong>#{gallery_count}</strong> #{'gallery'.pluralize(gallery_count)}
    MSG
  end
end
