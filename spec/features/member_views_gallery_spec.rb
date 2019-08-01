# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'member views gallery', type: :feature do

    scenario 'member views gallery index' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_galleries_index

      they_should_see_galleries
      they_should_see_new_gallery_link
    end

    scenario 'member views gallery show for another user' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_a_gallery_path_for_another_user

      they_should_not_see_the_edit_gallery_link
      they_should_see_the_images_for_that_gallery
      they_should_see_the_gallery_name
      they_should_see_the_gallery_description
      they_should_see_the_gallery_owners_username
      they_should_see_a_link_to_the_gallery_owner
    end

    scenario 'member requests gallery edit for another user' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_request_a_gallery_edit_path_for_another_user

      they_should_be_redirected_to_home_page
      they_should_be_shown_an_error_message
    end

    scenario 'member requests gallery delete for another user' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      store_the_gallery_count

      when_they_request_a_gallery_delete_path_for_another_user
      they_should_be_redirected_to_home_page
      they_should_be_shown_an_error_message
      and_the_gallery_count_should_not_have_changed
    end

    scenario 'member views gallery show for a gallery they own' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_path_to_a_gallery_they_own

      they_should_see_the_images_for_that_gallery
      they_should_see_the_gallery_name
      they_should_see_the_gallery_description
      they_should_see_the_gallery_owners_username
      they_should_see_a_link_to_the_gallery_owner
      they_should_see_the_edit_gallery_link
    end

    scenario 'member clicks gallery edit button for a gallery they own' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_path_to_a_gallery_they_own
      given_they_click_the_gallery_edit_path

      they_should_be_directed_to_edit_gallery_page
    end

    ############################################################################

    def given_there_is_data_in_the_system
      users = 2.times.map { create(:user) }
      users.each do |user|
        2.times.map { create(:gallery, user: user) }
      end
      Gallery.all.each do |gallery|
        2.times.map { create(:image, gallery: gallery) }
      end
      expect(User.all.empty?).to be false
      expect(Gallery.all.empty?).to be false
      expect(Image.all.empty?).to be false

      random_order = users.shuffle
      @user        = random_order.first
      @other_user  = random_order.last

      @gallery       = @user.galleries.sample
      @other_gallery = @other_user.galleries.sample
    end

    def given_the_user_is_logged_in
      visit login_path
      fill_in 'email', with: @user.email
      fill_in 'password', with: @user.password
      click_button 'Log me in'
    end

    def given_they_visit_the_galleries_index
      visit galleries_path
    end

    def they_should_see_galleries
      Gallery.all.each do |gallery|
        expect(page).to have_link('', href: gallery_path(gallery.id))
      end
    end

    def they_should_see_new_gallery_link
      expect(page).to have_link('Create New Gallery', href: new_gallery_path)
    end

    ############################################################################

    def given_they_visit_a_gallery_path_for_another_user
      visit gallery_path(@other_gallery.id)
      @current_gallery = @other_gallery
    end

    def they_should_not_see_the_edit_gallery_link
      expect(page).to_not have_content('Edit this gallery')
      expect(page).to_not have_link('', href: edit_gallery_path(@current_gallery.id))
    end

    def they_should_see_the_images_for_that_gallery
      expect(@current_gallery.images.empty?).to be false
      @current_gallery.images.each do |image|
        expect(page).to have_link('', href: image_path(image.id))
      end
    end

    def they_should_see_the_gallery_name
      expect(page).to have_content(@current_gallery.name)
    end

    def they_should_see_the_gallery_description
      expect(page).to have_content(@current_gallery.description)
    end

    def they_should_see_the_gallery_owners_username
      expect(page).to have_content(@current_gallery.user.username)
    end

    def they_should_see_a_link_to_the_gallery_owner
      expect(page).to have_link('', href: user_path(@current_gallery.user.id))
    end

    ############################################################################

    def given_they_request_a_gallery_edit_path_for_another_user
      visit edit_gallery_path(@other_gallery.id)
    end

    def they_should_be_redirected_to_home_page
      expect(page).to have_current_path(home_path)
    end

    def they_should_be_shown_an_error_message
      expect(page).to have_content('Users can only amend their own galleries')
    end

    ############################################################################

    def store_the_gallery_count
      @initial_gallery_count = Gallery.count
    end

    def when_they_request_a_gallery_delete_path_for_another_user
      page.driver.submit :delete, gallery_path(@other_gallery.id), {}
    end

    def and_the_gallery_count_should_not_have_changed
      expect(Gallery.count).to eq @initial_gallery_count
    end

    ############################################################################

    def given_they_visit_the_path_to_a_gallery_they_own
      visit gallery_path(@gallery.id)
      @current_gallery = @gallery
    end

    def they_should_see_the_edit_gallery_link
      expect(page).to have_content('Edit this gallery')
      expect(page).to have_link('', href: edit_gallery_path(@current_gallery.id))
    end

    ############################################################################

    def given_they_click_the_gallery_edit_path
      click_link 'Edit this gallery'
    end

    def they_should_be_directed_to_edit_gallery_page
      expect(page).to have_current_path(edit_gallery_path(@current_gallery.id))
    end
  end
end
