# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:null_values) do
    [
      nil,
      '',
      ' ',
      '                       '
    ]
  end

  it 'is valid with valid attributes' do
    user = build(:user)
    expect(user).to be_valid
  end

  describe User, '#username' do
    let(:valid_usernames) do
      [
        'Paul Thompson',
        'dave1986',
        'emily@example.com',
        'a',
        '~&^U}@N% ^Y$TC£$}%R$V$^£"',
        'ȍ\򂡌ŽX/ٸǢʐՉ䄥y񡲠ذꐛٯ佶�˹ש;E繠'
      ]
    end

    it 'accepts valid usernames' do
      valid_usernames.each do |value|
        user = build(:user, username: value)
        expect(user.username).to eq value
        expect(user).to be_valid
      end
    end

    it 'is present' do
      null_values.each do |value|
        user = build(:user, username: value)
        expect(user).to_not be_valid
      end
    end

    it 'is unique' do
      valid_usernames.each do |value|
        user1 = create(:user, username: value)
        user2 = build(:user, username: value)
        expect(user1).to be_valid
        expect(user2).to_not be_valid
      end
    end

    it 'is no longer than 25 characters' do
      value = 'a' * 24
      user = build(:user, username: value)
      expect(user).to be_valid

      value = 'b' * 25
      user = build(:user, username: value)
      expect(user).to be_valid

      value = 'c' * 26
      user = build(:user, username: value)
      expect(user).to_not be_valid
    end
  end

  describe User, '#email' do
    let(:valid_emails) do
      %w[
        user@foo.com
        THE_USER@foo.bar.org
        first.last@foo.jp
      ]
    end

    it 'accepts valid email addresses' do
      valid_emails.each do |value|
        user = build(:user, email: value)
        expect(user.email).to eq value
        expect(user).to be_valid
      end
    end

    it 'is present' do
      null_values.each do |value|
        user = build(:user, email: value)
        expect(user).to_not be_valid
      end
    end

    # This is somewhat weird, because we must account for the auto-downcasing
    # of the email address. Thus, they give two different errors.
    it 'is unique' do
      %w[
        1user@foo.com
        1the_user@foo.bar.org
        1first.last@foo.jp
      ].each do |value|
        user1 = create(:user, email: value)
        expect do
          user2 = create(:user, email: value)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
      %w[
        2user@foo.COM
        2THE_USER@foo.bar.org
        2FIRST.LAST@FOO.JP
      ].each do |value|
        user1 = create(:user, email: value)
        expect do
          user2 = create(:user, email: value)
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    it 'is no longer than 255 characters' do
      value = '@' * 254
      user = build(:user, email: value)
      expect(user).to be_valid

      value = '@' * 255
      user = build(:user, email: value)
      expect(user).to be_valid

      value = '@' * 256
      user = build(:user, email: value)
      expect(user).to_not be_valid
    end

    it 'contains an at symbol' do
      %w[
        user.foo,com
        user_at_foo.org
        example.userkfoo.
      ].each do |value|
        user = build(:user, email: value)
        expect(user).to_not be_valid
      end
    end

    it 'downcases the email on save' do
      value = 'user@EXAMPLE.com'
      user = create(:user, email: value)
      expect(user.email).to_not eq value
      expect(user.email).to eq value.downcase
    end
  end

  describe User, '#password' do
    let(:valid_passwords) do
      %w[
        password
        user@foo.com
        first.last@foo.jp
        dave1986
        Y$TC£$}%R$V
        䄥y񡲠ذꐛٯ佶�˹ש;E繠
      ]
    end

    it 'accepts valid passwords' do
      valid_passwords.each do |value|
        user = build(:user, password: value, password_confirmation: value)
        expect(user.password).to eq value
        expect(user).to be_valid
      end
    end

    it 'is present' do
      null_values.each do |value|
        user = build(:user, password: value, password_confirmation: value)
        expect(user).to_not be_valid
      end
    end

    it 'is no shorter than 6 characters' do
      value = 'a' * 7
      user = build(:user, password: value, password_confirmation: value)
      expect(user).to be_valid

      value = 'b' * 6
      user = build(:user, password: value, password_confirmation: value)
      expect(user).to be_valid

      value = 'c' * 5
      user = build(:user, password: value, password_confirmation: value)
      expect(user).to_not be_valid
    end

    it 'requires a matching password confirmation' do
      [
        %w[password dpasswor],
        %w[password asswordp],
        %w[password passworda],
        %w[foo bar]
      ].each do |value, conf|
        user = build(:user, password: value, password_confirmation: conf)
        expect(user).to_not be_valid
      end
    end
  end
end
