FactoryGirl.define do
  factory :pledge do
    # By writing the association code below, we have two ways of creating
    # a pledge:
    # 1. By explicitly passing the user and campaigns records:
    # u = User.last
    # c = Campaign.last
    # FactoryGirl.create(:pledge, user: u, campaign: c)
    # 2. By not passing in the user and campaign options:
    # FactoryGirl.create(:pledge)
    # I the case above, FactoryGirl will create new user and campaign records
    # before create the pledge so the created pledge will be associated with
    # the newly created user and campaign

    association :user, factory: :user
    association :campaign, factory: :campaign

    amount { 1.5 + rand(1000) }
  end
end
