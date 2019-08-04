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
    sequence :password do |n|
      "foobarbaz_#{n}"
    end
    sequence :password_confirmation do |n|
      "foobarbaz_#{n}"
    end
  end

  factory :gallery do
    user
    sequence :name do |n|
      "Gallery name no. #{n}"
    end
    sequence :description do |n|
      "Gallery description no. #{n}"
    end
  end

  factory :image do
    gallery
    file do
      filepath = Rails.root.join('spec', 'support', 'assets', 'test_image.png')
      fixture_file_upload filepath, 'image/png'
    end
  end

end
