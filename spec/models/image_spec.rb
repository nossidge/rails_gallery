# frozen_string_literal: true

require 'rails_helper'
require './spec/support/image_helpers'

RSpec.configure do |config|
  config.include ImageHelpers
end

RSpec.describe Image, type: :model do

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
      stub_const('MEGABYTES', 1_048_576)

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

  describe Image, '#authorised?' do
    let(:image1) { create(:image) }
    let(:image2) { create(:image) }
    let(:image3) { create(:image) }

    it 'authorises the owner' do
      expect(image1.authorised?(image1.gallery.user)).to be true
      expect(image2.authorised?(image2.gallery.user)).to be true
      expect(image3.authorised?(image3.gallery.user)).to be true
    end

    it 'rejects other users' do
      expect(image1.authorised?(image2.gallery.user)).to be false
      expect(image1.authorised?(image3.gallery.user)).to be false
      expect(image2.authorised?(image1.gallery.user)).to be false
      expect(image2.authorised?(image3.gallery.user)).to be false
      expect(image3.authorised?(image1.gallery.user)).to be false
      expect(image3.authorised?(image2.gallery.user)).to be false
    end
  end
end
