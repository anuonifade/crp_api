FactoryBot.define do
  factory :user_without_referral do
    first_name { Faker::Name.first_name}
    last_name { Faker::Name.last_name }
    email {Faker::Internet.email}
    password {123456}
  end

  factory :user_with_referral do
    first_name { Faker::Name.first_name}
    last_name { Faker::Name.last_name }
    email {Faker::Internet.email}
    password {123456}
    referral_id {1}
    referral_token {Faker::Alphanumeric.alphanumeric(number: 16)}
  end
end