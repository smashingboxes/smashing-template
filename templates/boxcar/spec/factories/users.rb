# frozen_string_literal: true

FactoryBot.define do
  factory :user do |f|
    f.sequence(:email) { |n| "#{n}-#{Faker::Internet.email}" }
    password { "Secur3P@ssw0rd" }
  end
end
