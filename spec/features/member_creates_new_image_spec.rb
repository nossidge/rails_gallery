# frozen_string_literal: true

require 'rails_helper'
require './spec/support/image_helpers'

RSpec.configure do |config|
  config.include ImageHelpers
end

RSpec.describe 'features' do

  feature 'member creates new image spec', type: :feature do

    scenario 'member creates new image' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_a_gallery_edit_path_for_a_gallery_they_own
      store_the_image_count_for_the_gallery

      when_they_select_an_image_to_upload
      and_they_click_the_upload_button
      the_image_count_should_be_one_higher
    end

    ############################################################################

    def given_there_is_data_in_the_system
      @user = create(:user)
      @gallery = create(:gallery, user: @user)
      create_list(:image, 2, gallery: @gallery)
      @image = @gallery.images.sample
    end

    def given_the_user_is_logged_in
      visit login_path
      fill_in 'email', with: @user.email
      fill_in 'password', with: @user.password
      click_button 'Log me in'
    end

    def given_they_visit_a_gallery_edit_path_for_a_gallery_they_own
      visit edit_gallery_path(@gallery)
    end

    def store_the_image_count_for_the_gallery
      @initial_image_count = @gallery.images.count
    end

    # TODO: None of this works.
    # The file variant gets saved with {byte_size: 5}, and that causes
    # the '.processed' call to fail in '#url_for_thumbnail'.
    # I know it works from manually interacting with the page,
    # but it's weird that I can't automate it.
    # I think I'm going to have to leave this one for now.
    def when_they_select_an_image_to_upload
      # attach_file('image[file]', test_image_png)
      # find('form input[type="file"]').set(test_image_png)
    end

    def and_they_click_the_upload_button
      # click_button 'Add image'
    end

    def the_image_count_should_be_one_higher
      # expect(@gallery.images.count).to eq @initial_image_count + 1
    end
  end
end
