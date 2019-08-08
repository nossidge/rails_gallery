# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController, type: :controller do

  describe PagesController, '#me' do
    render_views

    it 'functions for logged in members' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_me_path

      they_should_see_their_own_data
      they_should_see_edit_user_link
      they_should_see_the_me_path_as_url
    end

    it 'functions for logged out visitors' do
      given_there_is_data_in_the_system
      given_the_user_is_not_logged_in
      given_they_visit_the_me_path

      they_should_be_redirected_to_login_page
    end

    ############################################################################

    def given_there_is_data_in_the_system
      @user = create(:user)
    end

    def given_the_user_is_logged_in
      visit login_path
      fill_in 'email',    with: @user.email
      fill_in 'password', with: @user.password
      click_button 'Log me in'
    end

    def given_they_visit_the_me_path
      visit me_path
    end

    def they_should_see_their_own_data
      expect(page).to have_content(@user.username)
      expect(page).to have_content(@user.email)
    end

    def they_should_see_edit_user_link
      expect(page).to have_content('Edit my information')
    end

    def they_should_see_the_me_path_as_url
      expect(page).to have_current_path(me_path)
    end

    ############################################################################

    def given_the_user_is_not_logged_in
      visit home_path
      expect(page).to have_link('', href: login_path)
    end

    def they_should_be_redirected_to_login_page
      expect(page).to have_current_path(login_path)
    end
  end
end
