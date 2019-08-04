# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'visitor views gallery', type: :feature do

    scenario 'visitor views gallery index' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      given_they_visit_the_galleries_index

      they_should_be_able_to_view_galleries
      they_should_not_see_edit_gallery_links
      they_should_see_a_signup_link
    end

    scenario 'visitor views gallery show' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      given_they_visit_a_specific_gallery

      they_should_not_see_the_edit_gallery_link
      they_should_see_the_images_for_that_gallery
      they_should_see_the_name_of_the_gallery
      they_should_see_the_description_of_the_gallery
      they_should_see_the_username_of_the_gallery_owner
      they_should_see_a_link_to_the_gallery_owner
    end

    scenario 'visitor requests gallery edit' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      given_they_request_a_gallery_edit_path

      they_should_be_redirected_to_login_page
      they_should_be_shown_an_error_message
    end

    scenario 'visitor requests gallery delete' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      store_the_gallery_count

      when_they_request_a_gallery_delete_path
      they_should_be_redirected_to_login_page
      they_should_be_shown_an_error_message
      the_gallery_count_should_not_have_changed
    end

    ############################################################################

    def given_there_is_data_in_the_system
      @gallery = create(:gallery)
      create_list(:image, 2, gallery: @gallery)
      expect(Gallery.all.empty?).to be false
      expect(Image.all.empty?).to be false
    end

    def given_the_user_is_not_logged_in
      visit home_path
      expect(page).to have_link('', href: login_path)
    end

    def given_they_visit_the_galleries_index
      visit galleries_path
    end

    def they_should_be_able_to_view_galleries
      Gallery.all.each do |gallery|
        expect(page).to have_link('', href: gallery_path(gallery))
      end
    end

    def they_should_not_see_edit_gallery_links
      Gallery.all.each do |gallery|
        expect(page).not_to have_link('', href: edit_gallery_path(gallery))
      end
    end

    def they_should_see_a_signup_link
      expect(page).to have_link('Sign up to add your own', href: signup_path)
    end

    ############################################################################

    def given_they_visit_a_specific_gallery
      visit gallery_path(@gallery)
    end

    def they_should_not_see_the_edit_gallery_link
      expect(page).not_to have_content('Edit this gallery')
      expect(page).not_to have_link('', href: edit_gallery_path(@gallery))
    end

    def they_should_see_the_images_for_that_gallery
      expect(@gallery.images.empty?).to be false
      @gallery.images.each do |image|
        expect(page).to have_link('', href: image_path(image))
      end
    end

    def they_should_see_the_name_of_the_gallery
      expect(page).to have_content(@gallery.name)
    end

    def they_should_see_the_description_of_the_gallery
      expect(page).to have_content(@gallery.description)
    end

    def they_should_see_the_username_of_the_gallery_owner
      expect(page).to have_content(@gallery.user.username)
    end

    def they_should_see_a_link_to_the_gallery_owner
      expect(page).to have_link('', href: user_path(@gallery.user))
    end

    ############################################################################

    def given_they_request_a_gallery_edit_path
      visit edit_gallery_path(@gallery)
    end

    def they_should_be_redirected_to_login_page
      expect(page).to have_current_path(login_path)
    end

    def they_should_be_shown_an_error_message
      expect(page).to have_content('To amend gallery details, please log in')
    end

    ############################################################################

    def store_the_gallery_count
      @initial_gallery_count = Gallery.count
    end

    def when_they_request_a_gallery_delete_path
      page.driver.submit :delete, gallery_path(@gallery), {}
    end

    def the_gallery_count_should_not_have_changed
      expect(Gallery.count).to eq @initial_gallery_count
    end
  end
end
