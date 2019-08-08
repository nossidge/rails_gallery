# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'member updates user', type: :feature do

    scenario 'member visits user edit page' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_their_own_user_edit_path

      they_should_see_forms_for_each_field
      they_should_see_the_username
      they_should_see_the_email
      they_should_not_see_the_password
      they_should_see_back_button
      they_should_see_delete_button
    end

    scenario 'member backs out of the user edit' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_their_own_user_edit_path
      given_they_click_the_back_button

      they_should_be_redirected_to_user_page
    end

    scenario 'member confirms to delete user profile' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_their_own_user_edit_path
      store_the_user_count

      when_they_click_the_delete_button
      they_should_be_redirected_to_users_index
      they_should_not_be_able_to_log_in
      they_should_not_be_able_to_view_old_user_page
      and_the_user_count_should_be_one_fewer
    end

    feature 'member submits update username form' do
      before do
        given_there_is_data_in_the_system
        given_the_user_is_logged_in
        given_they_visit_their_own_user_edit_path
      end

      scenario 'with valid username' do
        when_the_user_submits_the_username_form
        confirm_fields_updated(:username)
        confirm_fields_not_updated(:email, :password)
      end

      scenario 'with missing username' do
        when_the_user_submits_the_username_form(username: nil)
        confirm_fields_not_updated(:username, :email, :password)
        confirm_error("Username can't be blank")
      end

      scenario 'with duplicate username' do
        params = { username: @different_user.username }
        when_the_user_submits_the_username_form(params)
        confirm_fields_not_updated(:username, :email, :password)
        confirm_error('Username has already been taken')
      end
    end

    feature 'member submits update email form' do
      before do
        given_there_is_data_in_the_system
        given_the_user_is_logged_in
        given_they_visit_their_own_user_edit_path
      end

      scenario 'with valid email' do
        when_the_user_submits_the_email_form
        confirm_fields_updated(:email)
        confirm_fields_not_updated(:username, :password)
      end

      scenario 'with missing email' do
        when_the_user_submits_the_email_form(email: nil)
        confirm_fields_not_updated(:username, :email, :password)
        confirm_error("Email can't be blank")
      end

      scenario 'with invalid email' do
        when_the_user_submits_the_email_form(email: 'no_at_symbol')
        confirm_fields_not_updated(:username, :email, :password)
        confirm_error('Email is invalid')
      end

      scenario 'with duplicate email' do
        params = { email: @different_user.email }
        when_the_user_submits_the_email_form(params)
        confirm_fields_not_updated(:username, :email, :password)
        confirm_error('Email has already been taken')
      end
    end

    feature 'member submits update password form' do
      before do
        given_there_is_data_in_the_system
        given_the_user_is_logged_in
        given_they_visit_their_own_user_edit_path
      end

      scenario 'with valid password' do
        when_the_user_submits_the_password_form
        confirm_fields_updated(:password)
        confirm_fields_not_updated(:username, :email)
      end

      scenario 'with missing password' do
        params = { password: nil, password_conf: nil }
        when_the_user_submits_the_password_form(params)
        confirm_fields_not_updated(:username, :email, :password)
        confirm_error("Password can't be blank")
      end

      scenario 'with invalid password' do
        params = { password: '2_sml', password_conf: '2_sml' }
        when_the_user_submits_the_password_form(params)
        confirm_fields_not_updated(:username, :email, :password)
        confirm_error('Password is too short (minimum is 6 characters)')
      end

      scenario 'with invalid password confirmation' do
        params = { password: 'p4ssw0rd', password_conf: 'password' }
        when_the_user_submits_the_password_form(params)
        confirm_fields_not_updated(:username, :email, :password)
        confirm_error("Password confirmation doesn't match Password")
      end
    end

    ############################################################################
    #
    # Common methods
    #
    def given_there_is_data_in_the_system
      @original_user  = create(:user)
      @new_data       = build(:user)
      @different_user = create(:user)
    end

    def given_the_user_is_logged_in
      visit login_path
      fill_in 'email',    with: @original_user.email
      fill_in 'password', with: @original_user.password
      click_button 'Log me in'
    end

    def given_they_visit_their_own_user_edit_path
      visit edit_user_path(@original_user)
    end

    # The default here is that the informaton is valid.
    # Change the argument if you want the field to be invalid.
    def when_the_user_submits_the_username_form(
      username: @new_data.username
    )
      fill_in 'user_username', with: username
      find("[@id='submit_username']").click
    end

    def when_the_user_submits_the_email_form(
      email: @new_data.email
    )
      fill_in 'user_email', with: email
      find("[@id='submit_email']").click
    end

    def when_the_user_submits_the_password_form(
      password: @new_data.password,
      password_conf: @new_data.password
    )
      fill_in 'user_password', with: password
      fill_in 'user_password_confirmation', with: password_conf
      find("[@id='submit_password']").click
    end

    # Make sure the saved data now matches the '@new_data' info
    def confirm_fields_updated(*fields)
      compare_fields(@new_data, fields)
    end

    # Make sure the saved data still matches the '@original_user' info
    def confirm_fields_not_updated(*fields)
      compare_fields(@original_user, fields)
    end

    def compare_fields(user_from_factory, fields)
      user = User.find(@original_user.id)
      if fields.delete(:password)
        password_auth = user.reload.authenticate(user_from_factory.password)
        expect(password_auth).not_to be false
      end
      fields.each do |field|
        expect(user[field]).to eq user_from_factory[field]
      end
    end

    def confirm_error(error_message)
      expect(page).to have_content(error_message)
    end

    ############################################################################

    def they_should_see_forms_for_each_field
      expect(page).to have_xpath("//form[@id='edit_username']")
      expect(page).to have_xpath("//form[@id='edit_email']")
      expect(page).to have_xpath("//form[@id='edit_password']")
    end

    def they_should_see_the_username
      elem = page.find('td', id: 'value-username')
      expect(elem.text).to eq @original_user.username
      elem = page.find('input', id: 'user_username')
      expect(elem.value).to eq @original_user.username
    end

    def they_should_see_the_email
      elem = page.find('td', id: 'value-email')
      expect(elem.text).to eq @original_user.email
      elem = page.find('input', id: 'user_email')
      expect(elem.value).to eq @original_user.email
    end

    def they_should_not_see_the_password
      elem = page.find('td', id: 'value-password')
      expect(elem.text).to eq '••••••'
      elem = page.find('input', id: 'user_password')
      expect(elem.value).to eq nil
      elem = page.find('input', id: 'user_password_confirmation')
      expect(elem.value).to eq nil
    end

    def they_should_see_back_button
      path = user_path(@original_user)
      expect(page).to have_link('Back to profile', href: path)
    end

    def they_should_see_delete_button
      path = user_path(@original_user)
      expect(page).to have_link('Delete my account', href: path)
    end

    ############################################################################

    def given_they_click_the_back_button
      click_link 'Back to profile'
    end

    def they_should_be_redirected_to_user_page
      expect(page).to have_current_path(user_path(@original_user))
    end

    ############################################################################

    def store_the_user_count
      @initial_user_count = User.count
    end

    def when_they_click_the_delete_button
      click_link 'Delete my account'
    end

    def they_should_be_redirected_to_users_index
      expect(page).to have_current_path(users_path)
    end

    def they_should_not_be_able_to_log_in
      visit login_path
      fill_in 'email',    with: @original_user.email
      fill_in 'password', with: @original_user.password
      click_button 'Log me in'
      expect(page).to have_content('Email or password is invalid')
    end

    def they_should_not_be_able_to_view_old_user_page
      expect do
        visit user_path(@original_user)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    def and_the_user_count_should_be_one_fewer
      expect(User.count).to eq @initial_user_count - 1
    end
  end
end
