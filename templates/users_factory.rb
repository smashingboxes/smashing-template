FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "#{n}-#{Faker::Internet.email}" }
    password { "Secur3P@ssw0rd" }
  end
end
