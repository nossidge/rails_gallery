# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do

  describe '#example_image_for_user' do

    it 'returns nil when given a User with no galleries' do
      user = create(:user)
      expect(helper.example_image_for_user(user)).to be nil
    end

    it 'returns nil when given a User with no images' do
      gallery = create(:gallery)
      user = gallery.user
      expect(helper.example_image_for_user(user)).to be nil
    end

    it 'returns the only image when given a User with one image' do
      image = create(:image)
      gallery = image.gallery
      user = gallery.user
      expect(helper.example_image_for_user(user)).to eq image
    end

    it 'returns the first image when given a User with many images' do
      image = create(:image)
      gallery = image.gallery
      create_list(:image, 3, gallery: gallery)
      user = gallery.user
      expect(helper.example_image_for_user(user)).to eq image
    end

    # ...when given a User with many images in many galleries
    it 'returns the first image in the first gallery' do
      user = create(:user)
      gallery = create(:gallery, user: user)
      create_list(:gallery, 3, user: user)
      image = create(:image, gallery: gallery)
      user.galleries.each do |g|
        create_list(:image, 3, gallery: g)
      end
      expect(helper.example_image_for_user(user)).to eq image
    end
  end

  describe '#display_image_and_gallery_count' do

    it 'functions when user has { galleries: 0, images: 0 }' do
      test_with(galleries: 0, images: 0)
    end

    it 'functions when user has { galleries: 1, images: 0 }' do
      test_with(galleries: 1, images: 0)
    end

    it 'functions when user has { galleries: 3, images: 0 }' do
      test_with(galleries: 3, images: 0)
    end

    it 'functions when user has { galleries: 1, images: 1 }' do
      test_with(galleries: 1, images: 1)
    end

    it 'functions when user has { galleries: 3, images: 3 }' do
      test_with(galleries: 3, images: 3)
    end

    it 'functions when user has { galleries: 2, images: 12 }' do
      test_with(galleries: 2, images: 12)
    end

    def test_with(counts)
      user = create_user_with(counts)
      results_are_valid(user, counts)
    end

    def create_user_with(counts)
      create(:user).tap do |user|
        galleries = create_list(:gallery, counts[:galleries], user: user)
        counts[:images].times do
          create(:image, gallery: galleries.sample)
        end
      end
    end

    def results_are_valid(user, counts)
      result = helper.display_image_and_gallery_count(user)
      expect(result).to eq generated_html(counts[:images], counts[:galleries])
    end

    def generated_html(images_count, gallery_count)
      <<~MSG.strip
        User has
        <strong>#{images_count}</strong> #{'image'.pluralize(images_count)}
        in
        <strong>#{gallery_count}</strong> #{'gallery'.pluralize(gallery_count)}
      MSG
    end
  end
end
