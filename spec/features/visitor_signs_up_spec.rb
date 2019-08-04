# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'visitor signs up', type: :feature do

    before do
      given_the_data_is_ready
      given_the_user_is_not_logged_in
    end

    scenario 'with valid details' do
      store_the_user_count
      when_the_user_submits_the_form
      they_should_be_logged_in
      they_should_be_redirected_to_their_profile_page
      the_user_count_should_be_one_higher
    end

    scenario 'with all fields missing' do
      when_the_user_submits_the_form(
        username:      nil,
        email:         nil,
        password:      nil,
        password_conf: nil
      )
      confirm_error("Username can't be blank")
      confirm_error("Email can't be blank")
      confirm_error('Email is invalid')
      confirm_error("Password can't be blank")
      confirm_error('Password is too short (minimum is 6 characters)')
      confirm_error("Password confirmation doesn't match Password")
    end

    scenario 'with missing username' do
      when_the_user_submits_the_form(username: nil)
      confirm_error("Username can't be blank")
    end

    scenario 'with duplicate username' do
      when_the_user_submits_the_form(username: @different_user.username)
      confirm_error('Username has already been taken')
    end

    scenario 'with missing email' do
      when_the_user_submits_the_form(email: nil)
      confirm_error("Email can't be blank")
    end

    scenario 'with invalid email' do
      when_the_user_submits_the_form(email: 'no_at_symbol')
      confirm_error('Email is invalid')
    end

    scenario 'with duplicate email' do
      when_the_user_submits_the_form(email: @different_user.email)
      confirm_error('Email has already been taken')
    end

    scenario 'with missing password' do
      when_the_user_submits_the_form(password: nil, password_conf: nil)
      confirm_error("Password can't be blank")
    end

    scenario 'with invalid password' do
      when_the_user_submits_the_form(password: '2_sml', password_conf: '2_sml')
      confirm_error('Password is too short (minimum is 6 characters)')
    end

    scenario 'with invalid password confirmation' do
      when_the_user_submits_the_form(
        password:      'p4ssw0rd',
        password_conf: 'password'
      )
      confirm_error("Password confirmation doesn't match Password")
    end

    scenario 'clicking the cancel button' do
      given_the_user_visits_signup_path
      given_the_user_clicks_the_cancel_button
      they_should_be_redirected_to_home_page
    end

    ############################################################################

    def given_the_data_is_ready
      @original_user  = create(:user)
      @new_data       = build(:user)
      @different_user = create(:user)
    end

    def given_the_user_is_not_logged_in
      visit home_path
      expect(page).to have_link('', href: login_path)
    end

    ############################################################################

    # The default here is that the informaton is valid.
    # Change the argument if you want the field to be invalid.
    def when_the_user_submits_the_form(
      username:      @new_data.username,
      email:         @new_data.email,
      password:      @new_data.password,
      password_conf: @new_data.password
    )
      visit signup_path
      fill_in 'user_username',              with: username
      fill_in 'user_email',                 with: email
      fill_in 'user_password',              with: password
      fill_in 'user_password_confirmation', with: password_conf
      click_button 'Sign me up'
    end

    def confirm_error(error_message)
      expect(page).to have_content(error_message)
    end

    ############################################################################

    def store_the_user_count
      @initial_user_count = User.count
    end

    def they_should_be_logged_in
      @user = User.find_by(email: @new_data.email)
      expect(page).to have_content(/Logged in as.*#{@user.username}/)
    end

    def they_should_be_redirected_to_their_profile_page
      expect(page).to have_current_path(user_path(@user))
    end

    def the_user_count_should_be_one_higher
      expect(User.count).to eq @initial_user_count + 1
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
