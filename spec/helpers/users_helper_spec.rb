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
      3.times { create(:image, gallery: gallery) }
      user = gallery.user
      expect(helper.example_image_for_user(user)).to eq image
    end

    it 'returns the first image in the first gallery when given a User with many images in many galleries' do
      user = create(:user)
      gallery = create(:gallery, user: user)
      3.times { create(:gallery, user: user) }
      image = create(:image, gallery: gallery)
      user.galleries.each do |gallery|
        3.times { create(:image, gallery: gallery) }
      end
      expect(helper.example_image_for_user(user)).to eq image
    end
  end
end
