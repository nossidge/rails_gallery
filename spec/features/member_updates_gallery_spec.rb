# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'member updates gallery', type: :feature do

    scenario 'member visits gallery edit page' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_a_gallery_edit_path_for_a_gallery_they_own

      they_should_see_edit_gallery_collapse_button
      they_should_see_a_link_back_to_the_gallery
      they_should_see_a_link_to_delete_the_gallery
      they_should_see_a_choose_file_to_upload_element
    end

    scenario 'member clicks edit gallery info collapse button' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_a_gallery_edit_path_for_a_gallery_they_own
      given_they_click_collapse_button

      they_should_see_the_edit_gallery_form
      the_name_field_should_be_filled_in
      the_description_field_should_be_filled_in
    end

    scenario 'member confirms to delete gallery' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_a_gallery_edit_path_for_a_gallery_they_own
      store_the_gallery_count

      when_they_click_the_delete_button
      they_should_be_redirected_to_galleries_index
      they_should_not_be_able_to_view_old_gallery_page
      and_the_gallery_count_should_be_one_fewer
    end

    feature 'member submits form' do
      before do
        given_there_is_data_in_the_system
        given_the_user_is_logged_in
        given_they_visit_a_gallery_edit_path_for_a_gallery_they_own
      end

      scenario 'with valid details' do
        when_the_user_submits_the_form
        confirm_fields_updated
      end

      scenario 'with all fields missing' do
        when_the_user_submits_the_form(name: nil, description: nil)
        confirm_fields_not_updated
        confirm_error("Name can't be blank")
        confirm_error('Name is too short (minimum is 3 characters)')
      end

      scenario 'with missing name' do
        when_the_user_submits_the_form(name: nil)
        confirm_fields_not_updated
        confirm_error("Name can't be blank")
        confirm_error('Name is too short (minimum is 3 characters)')
      end

      scenario 'with name too short' do
        when_the_user_submits_the_form(name: 'aa')
        confirm_fields_not_updated
        confirm_error('Name is too short (minimum is 3 characters)')
      end

      scenario 'with name too long' do
        when_the_user_submits_the_form(name: 'a' * 51)
        confirm_fields_not_updated
        confirm_error('Name is too long (maximum is 50 characters)')
      end

      scenario 'with description too long' do
        when_the_user_submits_the_form(description: 'a' * 256)
        confirm_fields_not_updated
        confirm_error('Description is too long (maximum is 255 characters)')
      end
    end

    ############################################################################
    #
    # Common methods
    #
    def given_there_is_data_in_the_system
      @gallery  = create(:gallery)
      @new_data = build(:gallery)
      @user     = @gallery.user
    end

    def given_the_user_is_logged_in
      visit login_path
      fill_in 'email',    with: @user.email
      fill_in 'password', with: @user.password
      click_button 'Log me in'
    end

    def given_they_visit_a_gallery_edit_path_for_a_gallery_they_own
      visit edit_gallery_path(@gallery)
    end

    # The default here is that the informaton is valid.
    # Change the argument if you want the field to be invalid.
    def when_the_user_submits_the_form(
      name:        'new name',
      description: 'new description'
    )
      fill_in 'gallery_name',        with: name
      fill_in 'gallery_description', with: description
      click_button 'Update gallery info'
    end

    # Make sure the saved data now matches the '@new_data' info
    def confirm_fields_updated
      gallery = Gallery.find(@gallery.id)
      expect(gallery.name).to eq 'new name'
      expect(gallery.description).to eq 'new description'
    end

    # Make sure the saved data still matches the '@original_user' info
    def confirm_fields_not_updated
      gallery = Gallery.find(@gallery.id)
      expect(gallery.name).not_to eq 'new name'
      expect(gallery.description).not_to eq 'new description'
    end

    def confirm_error(error_message)
      expect(page).to have_content(error_message)
    end

    ############################################################################

    # We are not using a javascript engine, so we can't see the toggle.
    # We will instead check that the HTML exists that would allow it.
    def they_should_see_edit_gallery_collapse_button
      elem = page.find('button', text: 'Edit gallery info')
      expect(elem['data-toggle']).to eq 'collapse'
      expect(elem['data-target']).to eq '#edit-gallery'
    end

    def they_should_see_a_link_back_to_the_gallery
      expect(page).to have_link('View gallery', href: gallery_path(@gallery))
    end

    def they_should_see_a_link_to_delete_the_gallery
      expect(page).to have_link('Delete this gallery')
    end

    def they_should_see_a_choose_file_to_upload_element
      expect(page).to have_xpath("//input[@type='file'][@id='image_file']")
    end

    ############################################################################

    # No javascript engine, so just query the HTML.
    def given_they_click_collapse_button; end

    def they_should_see_the_edit_gallery_form
      expect(page).to have_xpath("//form[@id='edit_gallery_1']")
    end

    def the_name_field_should_be_filled_in
      elem = page.find('input', id: 'gallery_name')
      expect(elem.value).to eq @gallery.name
    end

    def the_description_field_should_be_filled_in
      elem = page.find('textarea', id: 'gallery_description')
      expect(elem.value).to eq @gallery.description
    end

    ############################################################################

    def store_the_gallery_count
      @initial_gallery_count = Gallery.count
    end

    def when_they_click_the_delete_button
      click_link 'Delete this gallery'
    end

    def they_should_be_redirected_to_galleries_index
      expect(page).to have_current_path(galleries_path)
    end

    def they_should_not_be_able_to_view_old_gallery_page
      expect do
        visit gallery_path(@gallery)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    def and_the_gallery_count_should_be_one_fewer
      expect(Gallery.count).to eq @initial_gallery_count - 1
    end
  end
end
