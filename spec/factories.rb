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
  end

end
