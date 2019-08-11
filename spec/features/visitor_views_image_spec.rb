# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'visitor views image', type: :feature do

    scenario 'visitor views image index' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      given_they_visit_the_images_index

      they_should_be_able_to_view_images
      they_should_see_a_signup_link
    end

    scenario 'visitor views image show' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      given_they_visit_a_specific_image

      they_should_see_a_link_back_to_the_gallery
      they_should_not_see_delete_image_link
    end

    scenario 'visitor requests image delete' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      store_the_image_count

      when_they_request_an_image_delete_path
      they_should_be_redirected_to_login_page
      they_should_be_shown_an_error_message
      the_image_count_should_not_have_changed
    end

    ############################################################################

    def given_there_is_data_in_the_system
      @gallery = create(:gallery)
      create_list(:image, 2, gallery: @gallery)
      @image = Image.first
      expect(Gallery.all.empty?).to be false
      expect(Image.all.empty?).to be false
    end

    def given_the_user_is_not_logged_in
      visit home_path
      expect(page).to have_link('', href: login_path)
    end

    def given_they_visit_the_images_index
      visit images_path
    end

    def they_should_be_able_to_view_images
      Image.all.each do |image|
        expect(page).to have_link('', href: image_path(image))
      end
    end

    def they_should_see_a_signup_link
      expect(page).to have_link('Sign up to add your own', href: signup_path)
    end

    ############################################################################

    def given_they_visit_a_specific_image
      visit image_path(@image)
    end

    def they_should_see_a_link_back_to_the_gallery
      expect(page).to have_link('', href: gallery_path(@gallery))
    end

    def they_should_not_see_delete_image_link
      expect(page).not_to have_content('Delete image')
    end

    ############################################################################

    def store_the_image_count
      @initial_image_count = Image.count
    end

    def when_they_request_an_image_delete_path
      page.driver.submit :delete, image_path(@image), {}
    end

    def they_should_be_redirected_to_login_page
      expect(page).to have_current_path(login_path)
    end

    def they_should_be_shown_an_error_message
      expect(page).to have_content('To amend image details, please log in')
    end

    def the_image_count_should_not_have_changed
      expect(Image.count).to eq @initial_image_count
    end
  end
end
