# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  describe SessionsController, '#new' do
    it 'returns http success' do
      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe SessionsController, '#create' do
    it 'is successful with valid credentials' do
      expect(session[:user_id]).to eq nil

      user = create(:user)
      get :create, params: {email: user.email, password: user.password}

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(home_url)
      expect(flash[:notice]).to eq "Welcome back #{user.username}!"
      expect(session[:user_id]).to eq user.id
    end

    it 'redirects to login screen on failure' do
      user = create(:user)
      email = user.email
      password = user.password

      get :create
      expect(response).to have_http_status(:success)
      expect(flash[:alert]).to eq 'Email or password is invalid'

      get :create, params: {email: email}
      expect(response).to have_http_status(:success)
      expect(flash[:alert]).to eq 'Email or password is invalid'

      get :create, params: {password: password}
      expect(response).to have_http_status(:success)
      expect(flash[:alert]).to eq 'Email or password is invalid'

      email = 'non@existant.com'
      password = 'foobarbaz'
      get :create, params: {email: email, password: password}
      expect(response).to have_http_status(:success)
      expect(flash[:alert]).to eq 'Email or password is invalid'
    end
  end

  describe SessionsController, '#destroy' do
    it 'clears the user from the session' do
      session[:user_id] = 1
      get :destroy

      expect(session[:user_id]).to be_nil
    end

    it 'sets a goodbye message flash' do
      get :destroy

      expect(flash[:notice]).to eq 'Logged out! See you later :-)'
    end

    it 'redirects to home page' do
      get :destroy

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(home_url)
    end
  end
end
