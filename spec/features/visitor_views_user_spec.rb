# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'visitor views user', type: :feature do

    scenario 'visitor views user index' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      given_they_visit_the_users_index
      they_should_be_able_to_view_users
      they_should_see_a_signup_link
    end

    scenario 'visitor views user show' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      given_they_visit_a_specific_user
      they_should_be_able_to_view_username
      they_should_be_able_to_view_the_galleries_for_that_user
      they_should_not_be_able_to_view_user_email
      they_should_not_be_able_to_see_edit_user_links
      they_should_not_be_able_to_see_edit_gallery_links
    end

    scenario 'visitor requests user edit' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      given_they_request_a_user_edit_path
      they_should_be_redirected_to_login_page
      they_should_be_shown_an_error_message
    end

    scenario 'visitor requests user delete' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      store_the_user_count

      when_they_request_a_user_delete_path
      they_should_be_redirected_to_login_page
      they_should_be_shown_an_error_message
      and_the_user_count_should_not_have_changed
    end

    ############################################################################

    def given_there_is_data_in_the_system
      @user = create(:user)
      @gallery = create(:gallery, user: @user)
      expect(User.all.empty?).to be false
      expect(Gallery.all.empty?).to be false
    end

    def given_the_user_is_not_logged_in
      visit home_path
      expect(page).to have_link('', href: login_path)
    end

    def given_they_visit_the_users_index
      visit users_path
    end

    def they_should_be_able_to_view_users
      User.all.each do |user|
        expect(page).to have_link('', href: user_path(user.id))
      end
    end

    def they_should_see_a_signup_link
      expect(page).to have_link('Sign up to add your own', href: signup_path)
    end

    ############################################################################

    def given_they_visit_a_specific_user
      visit user_path(@user.id)
    end

    def they_should_be_able_to_view_username
      expect(page).to have_content(@user.username)
    end

    def they_should_be_able_to_view_the_galleries_for_that_user
      expect(@user.galleries.empty?).to be false
      @user.galleries.each do |gallery|
        expect(page).to have_link('', href: gallery_path(gallery.id))
      end
    end

    def they_should_not_be_able_to_view_user_email
      expect(page).to_not have_content(@user.email)
    end

    def they_should_not_be_able_to_see_edit_user_links
      expect(page).to_not have_content('Edit my information')
      expect(page).to_not have_content('Delete my account')
    end

    def they_should_not_be_able_to_see_edit_gallery_links
      @user.galleries.each do |gallery|
        expect(page).to_not have_link('', href: edit_gallery_path(gallery.id))
      end
    end

    ############################################################################

    def given_they_request_a_user_edit_path
      visit edit_user_path(@user.id)
    end
    def they_should_be_redirected_to_login_page
      expect(page).to have_current_path(login_path)
    end
    def they_should_be_shown_an_error_message
      expect(page).to have_content('To amend user details, please log in')
    end

    ############################################################################

    def store_the_user_count
      @initial_user_count = User.count
    end

    def when_they_request_a_user_delete_path
      page.driver.submit :delete, user_path(@user.id), {}
    end

    def and_the_user_count_should_not_have_changed
      expect(User.count).to eq @initial_user_count
    end
  end
end
