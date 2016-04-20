FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name   }
    last_name  { Faker::Name.last_name    }
    sequence(:email) { |n| Faker::Internet.email.gsub("@", "-#{n}@") }
    # sequence takes an email with var |n| -> guarantees uniqueness? adds -1, -2 etc to new emails
    password   { Faker::Internet.password }
  end
end
