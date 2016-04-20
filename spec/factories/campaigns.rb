FactoryGirl.define do
  # we define our factory for the Campaign model in here.
  # remember that this should always succeed in giving a valid campaign
  factory :campaign do
    sequence(:title) {|n| "#{Faker::Company.bs}-#{n}"}
    # this is now a dynamic method because of {}
    # title here is a method no brackets for static, {} for dynamic
    # using a sequence will guarantee us that we will have a unique number 'n'
    # which we can use to generate a unique title
    body             { Faker::Hipster.paragraph      }
    goal             { 11 + rand(100000)             }
    end_date         { Time.now + rand(100).days     }
    
  end
end
