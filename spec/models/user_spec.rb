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
        expect(user).not_to be_valid
      end
    end

    it 'is unique' do
      valid_usernames.each do |value|
        user1 = create(:user, username: value)
        user2 = build(:user, username: value)
        expect(user1).to be_valid
        expect(user2).not_to be_valid
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
      expect(user).not_to be_valid
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
        expect(user).not_to be_valid
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
        create(:user, email: value)
        expect do
          create(:user, email: value)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
      %w[
        2user@foo.COM
        2THE_USER@foo.bar.org
        2FIRST.LAST@FOO.JP
      ].each do |value|
        create(:user, email: value)
        expect do
          create(:user, email: value)
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
      expect(user).not_to be_valid
    end

    it 'contains an at symbol' do
      %w[
        user.foo,com
        user_at_foo.org
        example.userkfoo.
      ].each do |value|
        user = build(:user, email: value)
        expect(user).not_to be_valid
      end
    end

    it 'downcases the email on save' do
      value = 'user@EXAMPLE.com'
      user = create(:user, email: value)
      expect(user.email).not_to eq value
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
        expect(user).not_to be_valid
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
      expect(user).not_to be_valid
    end

    it 'requires a matching password confirmation' do
      [
        %w[password dpasswor],
        %w[password asswordp],
        %w[password passworda],
        %w[foo bar]
      ].each do |value, conf|
        user = build(:user, password: value, password_confirmation: conf)
        expect(user).not_to be_valid
      end
    end
  end

  describe User, '#authorised?' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }

    it 'authorises the owner' do
      expect(user1.authorised?(user1)).to be true
      expect(user2.authorised?(user2)).to be true
      expect(user3.authorised?(user3)).to be true
    end

    it 'rejects other users' do
      expect(user1.authorised?(user2)).to be false
      expect(user1.authorised?(user3)).to be false
      expect(user2.authorised?(user1)).to be false
      expect(user2.authorised?(user3)).to be false
      expect(user3.authorised?(user1)).to be false
      expect(user3.authorised?(user2)).to be false
    end
  end
end
