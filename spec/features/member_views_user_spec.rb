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
      they_should_not_see_edit_user_link
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

    scenario 'member views user show for their own account' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_user_path_for_their_own_account

      they_should_see_their_galleries
      they_should_see_their_username
      they_should_see_their_email
      they_should_see_edit_user_link
      they_should_see_edit_gallery_links
      they_should_see_new_gallery_link
    end

    scenario 'member clicks user edit button for their own account' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_user_path_for_their_own_account
      given_they_click_the_user_edit_path_for_their_own_account

      they_should_be_directed_to_edit_user_page
    end

    ############################################################################

    def given_there_is_data_in_the_system
      users = 3.times.map { create(:user) }
      users.each do |user|
        create_list(:gallery, 3, user: user)
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
        expect(page).to have_link('', href: user_path(user))
      end
    end

    def they_should_see_profile_view_link
      expect(page).to have_link('View your profile', href: user_path(@user))
    end

    ############################################################################

    def given_they_visit_a_user_path_for_another_user
      visit user_path(@other_user)
    end

    def they_should_see_the_galleries_for_that_user
      expect(@other_user.galleries.empty?).to be false
      @other_user.galleries.each do |gallery|
        expect(page).to have_link('', href: gallery_path(gallery))
      end
    end

    def they_should_see_username
      expect(page).to have_content(@other_user.username)
    end

    def they_should_not_see_user_email
      expect(page).not_to have_content(@other_user.email)
    end

    def they_should_not_see_edit_user_link
      expect(page).not_to have_content('Edit my information')
    end

    def they_should_not_see_edit_gallery_links
      @other_user.galleries.each do |gallery|
        expect(page).not_to have_link('', href: edit_gallery_path(gallery))
      end
    end

    ############################################################################

    def given_they_request_a_user_edit_path_for_another_user
      visit edit_user_path(@other_user)
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
      page.driver.submit :delete, user_path(@other_user), {}
    end

    def and_the_user_count_should_not_have_changed
      expect(User.count).to eq @initial_user_count
    end

    ############################################################################

    def given_they_visit_the_user_path_for_their_own_account
      visit user_path(@user)
    end

    def they_should_see_their_galleries
      expect(@user.galleries.empty?).to be false
      @user.galleries.each do |gallery|
        expect(page).to have_link('', href: gallery_path(gallery))
      end
    end

    def they_should_see_their_username
      expect(page).to have_content(@user.username)
    end

    def they_should_see_their_email
      expect(page).to have_content(@user.email)
    end

    def they_should_see_edit_user_link
      expect(page).to have_content('Edit my information')
    end

    def they_should_see_edit_gallery_links
      @user.galleries.each do |gallery|
        expect(page).to have_link('', href: edit_gallery_path(gallery))
      end
    end

    def they_should_see_new_gallery_link
      expect(page).to have_link('', href: new_gallery_path)
    end

    ############################################################################

    def given_they_click_the_user_edit_path_for_their_own_account
      click_link 'Edit my information'
    end

    def they_should_be_directed_to_edit_user_page
      expect(page).to have_current_path(edit_user_path(@user))
    end
  end
end
