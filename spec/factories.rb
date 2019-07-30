# frozen_string_literal: true

# Necessary to add 'fixture_file_upload' method
# https://blog.eq8.eu/til/factory-bot-trait-for-active-storange-has_attached.html
FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
end


FactoryBot.define do

  factory :user do
    sequence :username do |n|
      "John Testerton no. #{n}"
    end
    sequence :email do |n|
      "person_#{n}@example.com"
    end
    password do
      'foobarbaz'
    end
    password_confirmation do
      'foobarbaz'
    end
  end

  factory :gallery do
    user
    name { 'Example gallery text' }
    description { 'Example description' }
  end

  factory :image do
    gallery
    file do
      filepath = Rails.root.join('spec', 'support', 'assets', 'test_image.png')
      fixture_file_upload filepath, 'image/png'
    end
  end

end
