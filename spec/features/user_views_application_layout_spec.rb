# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'features' do

  # This is just for testing the top nav bar and footer.
  # Only difference should be the user menu in the top right for members
  #   and a 'log in' button for visitors.
  feature 'user views application layout', type: :feature do

    scenario 'visitor views home page' do
      given_the_user_is_not_logged_in

      they_should_see_nav_link_to_home
      they_should_see_nav_link_to_users
      they_should_see_nav_link_to_galleries
      they_should_see_nav_link_to_images
      they_should_see_footer

      they_should_see_nav_link_to_login
    end

    scenario 'member views home page' do
      given_there_is_data_in_the_system
      given_the_user_is_logged_in

      they_should_see_nav_link_to_home
      they_should_see_nav_link_to_users
      they_should_see_nav_link_to_galleries
      they_should_see_nav_link_to_images
      they_should_see_footer

      they_should_see_user_menu
    end

    ############################################################################

    def given_the_user_is_not_logged_in
      visit logout_path
    end

    def they_should_see_nav_link_to_home
      expect(page).to have_link('', href: home_path)
    end

    def they_should_see_nav_link_to_users
      expect(page).to have_link('Users', href: users_path)
    end

    def they_should_see_nav_link_to_galleries
      expect(page).to have_link('Galleries', href: galleries_path)
    end

    def they_should_see_nav_link_to_images
      expect(page).to have_link('Images', href: images_path)
    end

    def they_should_see_footer
      expect(page).to have_content('Rails Gallery by Paul Thompson')
      expect(page).to have_link('Back to top', href: '#')
    end

    def they_should_see_nav_link_to_login
      expect(page).to have_link('Log In', href: login_path)
    end

    ############################################################################

    def given_there_is_data_in_the_system
      @user = create(:user)
    end

    def given_the_user_is_logged_in
      visit login_path
      fill_in 'email', with: @user.email
      fill_in 'password', with: @user.password
      click_button 'Log me in'
    end

    def they_should_see_user_menu
      expect(page).to have_content(/Logged in as.*#{@user.username}/)
      expect(page).to have_link('View My Profile', href: user_path(@user.id))
      expect(page).to have_link('Create New Gallery', href: new_gallery_path)
      expect(page).to have_link('Log Out', href: logout_path)
    end
  end
end
