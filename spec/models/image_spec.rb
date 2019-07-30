# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Image, type: :model do

  ##
  # Create a temporary file and fill it with dummy data
  #
  # @param [Integer] bytes
  # @return [Tempfile]
  #
  def create_dummy_file(bytes)
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
  #
  def create_image(bytes, mime_type: 'image/png')
    filepath = create_dummy_file(bytes)
    file = fixture_file_upload(filepath, mime_type)
    create(:image, file: file)
  end

  ##############################################################################

  describe Image, '#file' do

    it 'accepts and attaches a valid file' do
      %w[
        image/png
        image/jpg
        image/jpeg
      ].each do |format|
        expect do
          create_image(4_096, mime_type: format)
        end.to change(ActiveStorage::Attachment, :count).by(1)
      end
    end

    it 'is a valid image file' do
      %w[
        application/zip
        audio/mpeg
        image/tiff
        text/plain
        video/jpeg
      ].each do |format|
        expect do
          create_image(4_096, mime_type: format)
        end.to raise_error(
          ActiveRecord::RecordInvalid,
          'Validation failed: File has an invalid content type'
        )
      end
    end

    it 'is smaller than 2MB' do
      MEGABYTES = 1_048_576

      expect do
        create_image(2 * MEGABYTES - 1)
      end.to change(ActiveStorage::Attachment, :count).by(1)

      expect do
        create_image(2 * MEGABYTES)
      end.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: File too large (must be below 2MB)'
      )

      expect do
        create_image(2 * MEGABYTES + 1)
      end.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: File too large (must be below 2MB)'
      )
    end
  end
end
