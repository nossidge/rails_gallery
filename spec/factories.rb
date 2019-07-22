FactoryBot.define do
  factory :gallery do
    name { "MyString" }
    description { "MyText" }
    user { nil }
  end


  factory :user, class: 'User' do

    sequence :username do |n|
      "John Testerton no. #{n}"
    end

    sequence :email do |n|
      "person_#{n}@example.com"
    end

    password              { 'foobarbaz' }
    password_confirmation { 'foobarbaz' }
  end

end
