# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'user logs in', type: :feature do

    def login_with(email, password)
      visit login_path
      fill_in 'email', with: email
      fill_in 'password', with: password

      click_button 'Log me in'
    end

    before(:each) do
      @password = 'valid_password'
      @user = create(:user, password: @password, password_confirmation: @password)
    end

    scenario 'with valid details' do
      login_with @user.email, @password

      expect(page).to have_current_path(home_path)
      expect(page).to have_content(/Welcome back #{@user.username}/)
    end

    scenario 'with all fields missing' do
      login_with nil, nil

      expect(page).to have_content('Email or password is invalid')
    end

    scenario 'with missing email' do
      login_with nil, @password

      expect(page).to have_content('Email or password is invalid')
    end

    scenario 'with incorrect email' do
      login_with 'this_email@does_not_exist.com', @password

      expect(page).to have_content('Email or password is invalid')
    end

    scenario 'with missing password' do
      login_with @user.email, nil

      expect(page).to have_content('Email or password is invalid')
    end

    scenario 'with incorrect password' do
      login_with @user.email, 'invalid_password'

      expect(page).to have_content('Email or password is invalid')
    end

    scenario 'clicking the cancel button' do
      visit signup_path
      click_link 'Cancel'

      expect(page).to have_current_path(home_path)
    end
  end
end
