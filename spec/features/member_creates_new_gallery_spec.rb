# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'member creates new gallery spec', type: :feature do

    scenario 'member visits new gallery page' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_new_gallery_page

      they_should_see_the_gallery_form
      they_should_see_a_cancel_button
    end

    # Data validation is the same as in the 'edit' route.
    # We should not need to repeat those tests.
    # Thus, just test that the happy path creates a new record.
    scenario 'member creates new gallery' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_the_new_gallery_page
      store_the_gallery_count_for_the_user

      when_the_user_submits_the_form_with_valid_details
      they_should_be_redirected_to_the_new_gallery_edit_path
      the_gallery_fields_should_match_what_was_entered
      the_gallery_count_should_be_one_higher
    end

    ############################################################################

    def given_there_is_data_in_the_system
      @user = create(:user)
      @gallery_info = build(:gallery, user: @user)
    end

    def given_the_user_is_logged_in
      visit login_path
      fill_in 'email', with: @user.email
      fill_in 'password', with: @user.password
      click_button 'Log me in'
    end

    def given_they_visit_the_new_gallery_page
      visit new_gallery_path
    end

    def they_should_see_the_gallery_form
      expect(page).to have_xpath("//form[@id='new_gallery']")
    end

    def they_should_see_a_cancel_button
      expect(page).to have_link('Cancel', href: user_path(@user))
    end

    ############################################################################

    def store_the_gallery_count_for_the_user
      @initial_gallery_count = @user.galleries.count
    end

    def when_the_user_submits_the_form_with_valid_details
      fill_in 'gallery_name', with: @gallery_info.name
      fill_in 'gallery_description', with: @gallery_info.description
      click_button 'Create new gallery'
    end

    # We are not redirecting to the 'show' path.
    # We redirect to 'edit' so the user can immediately start adding images.
    def they_should_be_redirected_to_the_new_gallery_edit_path
      @gallery = Gallery.order('created_at').last
      expect(page).to have_current_path(edit_gallery_path(@gallery))
    end

    def the_gallery_fields_should_match_what_was_entered
      expect(@gallery.name).to eq @gallery_info.name
      expect(@gallery.description).to eq @gallery_info.description
    end

    def the_gallery_count_should_be_one_higher
      expect(@user.galleries.count).to eq @initial_gallery_count + 1
    end
  end
end
