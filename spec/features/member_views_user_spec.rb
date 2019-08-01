# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'member views user', type: :feature do

    scenario 'member views user index' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_users_index

      they_should_see_users
      they_should_see_profile_view_link
    end

    scenario 'member views user show for another user' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_a_user_path_for_another_user

      they_should_see_the_galleries_for_that_user
      they_should_see_username
      they_should_not_see_user_email
      they_should_not_see_edit_user_links
      they_should_not_see_edit_gallery_links
    end

    scenario 'member requests user edit for another user' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_request_a_user_edit_path_for_another_user

      they_should_be_redirected_to_home_page
      they_should_be_shown_an_error_message
    end

    scenario 'member requests user delete for another user' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      store_the_user_count

      when_they_request_a_user_delete_path_for_another_user
      they_should_be_redirected_to_home_page
      they_should_be_shown_an_error_message
      and_the_user_count_should_not_have_changed
    end

    scenario 'member views user show for themselves' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_user_path_for_themselves

      they_should_see_their_galleries
      they_should_see_their_username
      they_should_see_their_email
      they_should_see_edit_user_links
      they_should_see_edit_gallery_links
      they_should_see_new_gallery_link
    end

    scenario 'member clicks user edit button for themselves' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_user_path_for_themselves
      given_they_click_the_user_edit_path_for_themselves

      they_should_be_directed_to_edit_user_page
    end

    scenario 'member clicks user delete button for themselves' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_user_path_for_themselves
      store_the_user_count

      when_they_click_the_user_delete_path_for_themselves
      they_should_be_shown_a_warning_dialog
      they_should_be_able_to_cancel_the_operation
      and_the_user_count_should_not_have_changed
    end

    ############################################################################

    def given_there_is_data_in_the_system
      users = 3.times.map { create(:user) }
      users.each do |user|
        3.times.map { create(:gallery, user: user) }
      end
      expect(User.all.empty?).to be false
      expect(Gallery.all.empty?).to be false

      random_order = users.shuffle
      @user        = random_order.first
      @other_user  = random_order.last
    end

    def given_the_user_is_logged_in
      visit login_path
      fill_in 'email', with: @user.email
      fill_in 'password', with: @user.password
      click_button 'Log me in'
    end

    def given_they_visit_the_users_index
      visit users_path
    end

    def they_should_see_users
      User.all.each do |user|
        expect(page).to have_link('', href: user_path(user.id))
      end
    end

    def they_should_see_profile_view_link
      expect(page).to have_link('View your profile', href: user_path(@user.id))
    end

    ############################################################################

    def given_they_visit_a_user_path_for_another_user
      visit user_path(@other_user.id)
    end

    def they_should_see_the_galleries_for_that_user
      expect(@other_user.galleries.empty?).to be false
      @other_user.galleries.each do |gallery|
        expect(page).to have_link('', href: gallery_path(gallery.id))
      end
    end

    def they_should_see_username
      expect(page).to have_content(@other_user.username)
    end

    def they_should_not_see_user_email
      expect(page).to_not have_content(@other_user.email)
    end

    def they_should_not_see_edit_user_links
      expect(page).to_not have_content('Edit my information')
      expect(page).to_not have_content('Delete my account')
    end

    def they_should_not_see_edit_gallery_links
      @other_user.galleries.each do |gallery|
        expect(page).to_not have_link('', href: edit_gallery_path(gallery.id))
      end
    end

    ############################################################################

    def given_they_request_a_user_edit_path_for_another_user
      visit edit_user_path(@other_user.id)
    end

    def they_should_be_redirected_to_home_page
      expect(page).to have_current_path(home_path)
    end

    def they_should_be_shown_an_error_message
      expect(page).to have_content('Users can only amend their own information')
    end

    ############################################################################

    def store_the_user_count
      @initial_user_count = User.count
    end

    def when_they_request_a_user_delete_path_for_another_user
      page.driver.submit :delete, user_path(@other_user.id), {}
    end

    def and_the_user_count_should_not_have_changed
      expect(User.count).to eq @initial_user_count
    end

    ############################################################################

    def given_they_visit_the_user_path_for_themselves
      visit user_path(@user.id)
    end

    def they_should_see_their_galleries
      expect(@user.galleries.empty?).to be false
      @user.galleries.each do |gallery|
        expect(page).to have_link('', href: gallery_path(gallery.id))
      end
    end

    def they_should_see_their_username
      expect(page).to have_content(@user.username)
    end

    def they_should_see_their_email
      expect(page).to have_content(@user.email)
    end

    def they_should_see_edit_user_links
      expect(page).to have_content('Edit my information')
      expect(page).to have_content('Delete my account')
    end

    def they_should_see_edit_gallery_links
      @user.galleries.each do |gallery|
        expect(page).to have_link('', href: edit_gallery_path(gallery.id))
      end
    end

    def they_should_see_new_gallery_link
      expect(page).to have_link('', href: new_gallery_path)
    end

    ############################################################################

    def given_they_click_the_user_edit_path_for_themselves
      click_link 'Edit my information'
    end

    def they_should_be_directed_to_edit_user_page
      expect(page).to have_current_path(edit_user_path(@user.id))
    end

    ############################################################################

    # Don't actually click the link.
    # We are not using a javascript engine, so we can't see the alert.
    def when_they_click_the_user_delete_path_for_themselves
    end

    # We will instead check that the HTML exists that would show the alert.
    def they_should_be_shown_a_warning_dialog
      elem = page.find('a', text: 'Delete my account')
      expect(elem['data-method']).to eq 'delete'
      expect(elem['data-confirm']).to eq "This will delete your entire account, including all galleries and images.\nAre you sure you want to do this?"
    end

    # See the above comments.
    # As long as 'data-confirm' exists, it should be valid.
    def they_should_be_able_to_cancel_the_operation
    end
  end
end
