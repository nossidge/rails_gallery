# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  feature 'member updates image', type: :feature do

    # There is no image edit route.
    # The only update verb is DELETE.
    scenario 'member visits image edit page' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_an_image_edit_path_for_an_image_they_own

      they_should_be_redirected_to_404_page
    end

    scenario 'member clicks image delete button' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in
      given_they_visit_an_image_show_path_for_an_image_they_own
      store_the_image_count

      when_they_click_the_delete_button
      they_should_be_redirected_to_images_index
      they_should_not_be_able_to_view_old_image_page
      and_the_image_count_should_be_one_fewer
    end

    ############################################################################

    def given_there_is_data_in_the_system
      @user = create(:user)
      @gallery = create(:gallery, user: @user)
      2.times.map { create(:image, gallery: @gallery) }
      @image = @gallery.images.sample
    end

    def given_the_user_is_logged_in
      visit login_path
      fill_in 'email', with: @user.email
      fill_in 'password', with: @user.password
      click_button 'Log me in'
    end

    # If the route is not available, then a 404 will be raised in production.
    def given_they_visit_an_image_edit_path_for_an_image_they_own
      expect do
        visit "/images/#{@image.id}/edit"
      end.to raise_error(ActionController::RoutingError)
    end

    def they_should_be_redirected_to_404_page; end

    ############################################################################

    def given_they_visit_an_image_show_path_for_an_image_they_own
      visit image_path(@image.id)
    end

    def store_the_image_count
      @initial_image_count = Image.count
    end

    def when_they_click_the_delete_button
      click_link 'Delete image'
    end

    def they_should_be_redirected_to_images_index
      expect(page).to have_current_path(gallery_path(@gallery.id))
    end

    def they_should_not_be_able_to_view_old_image_page
      expect do
        visit image_path(@image.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    def and_the_image_count_should_be_one_fewer
      expect(Image.count).to eq @initial_image_count - 1
    end
  end
end
