# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'user logs in', type: :feature do

    before do
      given_the_data_is_ready
      given_the_user_is_not_logged_in
    end

    scenario 'with valid details' do
      when_the_user_submits_the_form
      they_should_be_logged_in
      they_should_be_redirected_to_the_home_page
    end

    scenario 'with all fields missing' do
      when_the_user_submits_the_form(email: nil, password: nil)
      confirm_error('Email or password is invalid')
    end

    scenario 'with missing email' do
      when_the_user_submits_the_form(email: nil)
      confirm_error('Email or password is invalid')
    end

    scenario 'with incorrect email' do
      when_the_user_submits_the_form(email: 'email@does_not_exist.com')
      confirm_error('Email or password is invalid')
    end

    scenario 'with missing password' do
      when_the_user_submits_the_form(password: nil)
      confirm_error('Email or password is invalid')
    end

    scenario 'with incorrect password' do
      when_the_user_submits_the_form(password: 'invalid_password')
      confirm_error('Email or password is invalid')
    end

    scenario 'clicking the cancel button' do
      given_the_user_visits_signup_path
      given_the_user_clicks_the_cancel_button
      they_should_be_redirected_to_home_page
    end

    ############################################################################

    # The default here is that the information is valid.
    # Change the argument if you want the field to be invalid.
    def when_the_user_submits_the_form(
      email:    @user.email,
      password: @user.password
    )
      visit login_path
      fill_in 'email', with: email
      fill_in 'password', with: password
      click_button 'Log me in'
    end

    def confirm_error(error_message)
      expect(page).to have_content(error_message)
    end

    ############################################################################

    def given_the_data_is_ready
      @user = create(:user)
    end

    def given_the_user_is_not_logged_in
      visit home_path
      expect(page).to have_link('', href: login_path)
    end

    ############################################################################

    def they_should_be_logged_in
      user = User.find_by(email: @user.email)
      expect(page).to have_content(/Logged in as.*#{user.username}/)
    end

    def they_should_be_redirected_to_the_home_page
      expect(page).to have_current_path(home_path)
    end

    ############################################################################

    def given_the_user_visits_signup_path
      visit signup_path
    end

    def given_the_user_clicks_the_cancel_button
      click_link 'Cancel'
    end

    def they_should_be_redirected_to_home_page
      expect(page).to have_current_path(home_path)
    end
  end
end
