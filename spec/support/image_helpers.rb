# frozen_string_literal: true

module ImageHelpers
  ##
  # @return [Pathname] path of a valid test image
  #
  def test_image_png
    Rails.root.join('spec', 'support', 'assets', 'test_image.png')
  end

  ##
  # Create a temporary file and fill it with dummy data
  #
  # @param [Integer] bytes
  # @return [Tempfile]
  #
  def create_dummy_file(bytes = 4_096)
    Tempfile.new('image.png').tap do |filepath|
      content = 'a' * bytes
      File.write(filepath, content)
    end
  end

  ##
  # Create a dummy file, upload the file, and create an Image object
  # attaching the dummy file
  #
  # @param [Integer] bytes
  #   Size of the image in bytes
  # @param [String] mime_type
  #   The MIME type of the image
  #
  def create_image(bytes = 4_096, mime_type: 'image/png')
    filepath = create_dummy_file(bytes)
    file = fixture_file_upload(filepath, mime_type)
    create(:image, file: file)
  end
end
