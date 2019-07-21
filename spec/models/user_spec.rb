require 'rails_helper'

RSpec.describe User, type: :model do

  before(:each) do
    @user = User.new( {
      :username => 'Example User',
      :email => 'user@example.com',
      :password => 'foobarbaz',
      :password_confirmation => 'foobarbaz'
    } )
  end

  describe 'object instance' do
    subject { @user }
    it { is_expected.to be_valid }
    it { is_expected.to be_an_instance_of User }
    it { is_expected.to respond_to(:username) }
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:password) }
    it { is_expected.to respond_to(:password_confirmation) }
    it { is_expected.to respond_to(:password_digest) }
  end

  describe 'name validation' do
    subject { @user }

    it 'should require a name' do
      @user.username = ''
      expect(@user).to_not be_valid
    end
  end

  describe 'email validation' do
    it 'should require an email address' do
      @user.email = ''
      expect(@user).to_not be_valid
    end

    it 'should accept valid email addresses' do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        @user.email = address
        expect(@user).to be_valid
      end
    end

    # We are not doing any pointless email checking, other than an @.
    it 'should also ACCEPT invalid email addresses that contain @' do
      addresses = %w[user@foo,com user_at_foo.o@rg example.user@foo.]
      addresses.each do |address|
        @user.email = address
        expect(@user).to be_valid
      end
    end

    it 'should reject invalid email addresses with no @ sign' do
      addresses = %w[user.foo,com user_at_foo.org example.userkfoo.]
      addresses.each do |address|
        @user.email = address
        expect(@user).to_not be_valid
      end
    end
  end

  describe 'password validation' do
    it 'should require a password' do
      @user.password = ''
      @user.password_confirmation = ''
      expect(@user).to_not be_valid
    end

    it 'should require a matching password confirmation' do
      @user.password_confirmation = 'invalid'
      expect(@user).to_not be_valid
    end

    it 'should reject passwords shorter than 6 chars' do
      short = 'a' * 5
      @user.password = short
      @user.password_confirmation = short
      expect(@user).to_not be_valid
    end
  end
end
