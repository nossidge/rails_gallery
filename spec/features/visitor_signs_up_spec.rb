# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'visitor signs up', type: :feature do

    def sign_up_with(username, email, password, password_conf)
      visit signup_path
      fill_in 'user_username', with: username
      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      fill_in 'user_password_confirmation', with: password_conf

      click_button 'Sign me up'
    end

    before(:each) do
      @password = 'valid_password'
      @user = build(:user, password: @password, password_confirmation: @password)
    end

    scenario 'with valid details' do
      sign_up_with @user.username, @user.email, @password, @password

      user = User.find_by_email(@user.email)
      expect(page).to have_current_path(user_path(user.id))
      expect(page).to have_content(/Logged in as.*#{@user.username}/)
    end

    scenario 'with all fields missing' do
      sign_up_with nil, nil, nil, nil

      expect(page).to have_content("Username can't be blank")
      expect(page).to have_content("Email can't be blank")
      expect(page).to have_content('Email is invalid')
      expect(page).to have_content("Password can't be blank")
      expect(page).to have_content('Password is too short (minimum is 6 characters)')
      expect(page).to have_content("Password confirmation doesn't match Password")
    end

    scenario 'with missing username' do
      sign_up_with nil, @user.email, @password, @password

      expect(page).to have_content("Username can't be blank")
    end

    scenario 'with duplicate username' do
      @user.save
      sign_up_with @user.username, 'valid@example.com', @password, @password

      expect(page).to have_content('Username has already been taken')
    end

    scenario 'with missing email' do
      sign_up_with @user.username, nil, @password, @password

      expect(page).to have_content("Email can't be blank")
    end

    scenario 'with invalid email' do
      sign_up_with @user.username, 'invalid_email', @password, @password

      expect(page).to have_content('Email is invalid')
    end

    scenario 'with duplicate email' do
      @user.save
      sign_up_with 'valid_username', @user.email, @password, @password

      expect(page).to have_content('Email has already been taken')
    end

    scenario 'with missing password' do
      sign_up_with @user.username, @user.email, nil, nil

      expect(page).to have_content("Password can't be blank")
    end

    scenario 'with invalid password' do
      sign_up_with @user.username, @user.email, 'a', 'a'

      expect(page).to have_content('Password is too short (minimum is 6 characters)')
    end

    scenario 'with invalid password confirmation' do
      sign_up_with @user.username, @user.email, @password, 'invalid_password'

      expect(page).to have_content("Password confirmation doesn't match Password")
    end

    scenario 'clicking the cancel button' do
      visit signup_path
      click_link 'Cancel'

      expect(page).to have_current_path(home_path)
    end
  end
end
