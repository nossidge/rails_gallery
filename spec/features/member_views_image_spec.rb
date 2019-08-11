# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'member views image', type: :feature do

    scenario 'member views image index' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_images_index

      they_should_see_images
      they_should_see_new_gallery_link
    end

    scenario 'member views image show for another user' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_an_image_path_for_another_user

      they_should_see_the_full_image
      they_should_see_a_link_to_the_parent_gallery
      they_should_not_see_a_link_to_delete_image
    end

    scenario 'member requests image edit for another user' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_request_an_image_edit_path_for_another_user

      they_should_be_redirected_to_404_page
    end

    scenario 'member requests image delete for another user' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      store_the_image_count

      when_they_request_an_image_delete_path_for_another_user
      they_should_be_redirected_to_home_page
      they_should_be_shown_an_error_message
      and_the_image_count_should_not_have_changed
    end

    scenario 'member views image show for an image they own' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_path_to_an_image_they_own

      they_should_see_the_full_image
      they_should_see_a_link_to_the_parent_gallery
      they_should_see_the_delete_image_link
    end

    scenario 'member requests image edit for an image they own' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_request_an_image_edit_path_for_an_image_they_own

      they_should_be_redirected_to_404_page
    end

    scenario 'member clicks image delete button for an image they own' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_path_to_an_image_they_own
      store_the_image_count

      when_they_click_the_image_delete_path
      they_should_be_shown_a_warning_dialog
      they_should_be_able_to_cancel_the_operation
      and_the_image_count_should_not_have_changed
    end

    ############################################################################

    def given_there_is_data_in_the_system
      users = 2.times.map { create(:user) }
      users.each do |user|
        create_list(:gallery, 2, user: user)
      end
      Gallery.all.each do |gallery|
        create_list(:image, 2, gallery: gallery)
      end
      expect(User.all.empty?).to be false
      expect(Gallery.all.empty?).to be false
      expect(Image.all.empty?).to be false

      random_order = users.shuffle
      @user        = random_order.first
      @other_user  = random_order.last

      @gallery       = @user.galleries.sample
      @other_gallery = @other_user.galleries.sample

      @image       = @gallery.images.sample
      @other_image = @other_gallery.images.sample
    end

    def given_the_user_is_logged_in
      visit login_path
      fill_in 'email', with: @user.email
      fill_in 'password', with: @user.password
      click_button 'Log me in'
    end

    def given_they_visit_the_images_index
      visit images_path
    end

    def they_should_see_images
      Image.all.each do |image|
        expect(page).to have_link('', href: image_path(image))
      end
    end

    def they_should_see_new_gallery_link
      expect(page).to have_link('Create New Gallery', href: new_gallery_path)
    end

    ############################################################################

    def given_they_visit_an_image_path_for_another_user
      visit image_path(@other_image)
      @current_image = @other_image
    end

    def they_should_see_the_full_image
      image_url = rails_blob_path(@current_image.file, only_path: true)
      expect(page).to have_xpath("//img[@src='#{image_url}']")
    end

    def they_should_see_a_link_to_the_parent_gallery
      link = gallery_path(@current_image.gallery)
      expect(page).to have_link('', href: link)
    end

    def they_should_not_see_a_link_to_delete_image
      expect(page).not_to have_link('Delete image')
    end

    ############################################################################

    # If the route is not available, then a 404 will be raised in production.
    def given_they_request_an_image_edit_path_for_another_user
      expect do
        visit "/images/#{@other_image.id}/edit"
      end.to raise_error(ActionController::RoutingError)
    end

    def they_should_be_redirected_to_404_page; end

    ############################################################################

    def store_the_image_count
      @initial_image_count = Image.count
    end

    def when_they_request_an_image_delete_path_for_another_user
      page.driver.submit :delete, image_path(@other_image), {}
    end

    def they_should_be_redirected_to_home_page
      expect(page).to have_current_path(home_path)
    end

    def they_should_be_shown_an_error_message
      expect(page).to have_content('Users can only amend their own images')
    end

    def and_the_image_count_should_not_have_changed
      expect(Image.count).to eq @initial_image_count
    end

    ############################################################################

    def given_they_visit_the_path_to_an_image_they_own
      visit image_path(@image)
      @current_image = @image
    end

    def they_should_see_the_full_image
      image_url = rails_blob_path(@current_image.file, only_path: true)
      expect(page).to have_xpath("//img[@src='#{image_url}']")
    end

    def they_should_see_the_delete_image_link
      expect(page).to have_link('Delete image')
    end

    ############################################################################

    # If the route is not available, then a 404 will be raised in production.
    def given_they_request_an_image_edit_path_for_an_image_they_own
      expect do
        visit "/images/#{@image.id}/edit"
      end.to raise_error(ActionController::RoutingError)
    end

    ############################################################################

    # Don't actually click the link.
    # We are not using a javascript engine, so we can't see the alert.
    def when_they_click_the_image_delete_path; end

    # We will instead check that the HTML exists that would show the alert.
    def they_should_be_shown_a_warning_dialog
      elem = page.find(:xpath, "//a[@title='Delete image']")
      expect(elem['data-method']).to eq 'delete'
      expect(elem['data-confirm']).to eq <<~MSG.strip.sub("\n", ' ')
        This will delete the image from the server.
        Are you sure you want to do this?
      MSG
    end

    # See the above comments.
    # As long as 'data-confirm' exists, it should be valid.
    def they_should_be_able_to_cancel_the_operation; end
  end
end
