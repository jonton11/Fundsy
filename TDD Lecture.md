# TDD Lecture (Wednesday April 20th)

Begin by creating the `user` model in our `fundsy` application

```bash
bin/rails g model user first_name last_name email password_digest
bin/rake db:migrate
```

Navigate to `user_spec.rb` and add the 3 validation tests:

```ruby
# user_spec.rb

describe "validations" do
  it "requires a first name"
  it "requires a last name"
  it "requires an email"
end
```

We use `FactoryGirl` for the tests and make the changes in `users.rb`. Note that this is users (plural) and not `user.rb`.
```ruby
# users.rb

FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name   }
    last_name  { Faker::Name.last_name    }
    sequence(:email) { |n| Faker::Internet.email.gsub("@", "-#{n}@") }
    # sequence takes an email with var |n| -> guarantees uniqueness? adds -1, -2 etc to new emails
    password   { Faker::Internet.password }
  end
end
```

Then add the block to the tests

```ruby
# user_spec.rb

it "requires a first name" do
  u = User.new FactoryGirl.attributes_for(:user).merge({first_name: nil})
  # One line to set first_name attribute to nil
  expect(u).to be_invalid
end
# Similar for last_name and email
```

Test in the terminal line:
```bash
rspec ./spec/models/user_spec.rb:[line_where_test_is]
```

After failing the test once, validate in `user.rb`

```ruby
# user.rb

validates_presence_of :first_name, :last_name, :email
# I'm just doing all 3 at once here, all tests have been written and failed
```

Similarly for the method test:

```ruby
# user_spec.rb

it "returns concatenated first and last names" do
  u = User.new FactoryGirl.attributes_for(:user)
  # Instantiate a user here
  expect(u.full_name).to eq("#{u.first_name} #{u.last_name}")
end
```

After failing, head to `user.rb` since this is a `user` method

```ruby
# user.rb

def full_name
  "#{first_name} #{last_name}"
end
```

For a more secure test, we can adjust the test to prevent someone from knowing too much about the `.full_name` method as follows:

```ruby
# user_spec.rb

u = User.new FactoryGirl.attributes_for(:user).merge({first_name: "John", last_name: "Smith"})
expect(u.full_name).to eq("John Smith")
```

Now to `describe "hashing the password" do` :
```ruby
# user_spec.rb

it "generates a password digest" do
  u = User.new FactoryGirl.attributes_for(:user)
  u.save
  expect(u.password_digest).to be
end
#  Note: Don't forget to uncomment the bcrypt gem in your Gemfile
```

After failing, head to `user.rb` and replace `attr_accessor :password` with `has_secure_password`

Now we want to create a `user` in the controller. Begin in the terminal with
```bash
bin/rails g controller users
```

Because we have `rspec` installed, we can see that `spec/controllers/users_controller_spec.rb` is generated as well. Note that we will still be running these tests in the command line so make sure to have the correct path file, e.g.

```bash
rspec ./spec/controllers/users_controller_spec.rb:[line_where_test_is]
```

Now we create the following tests in our `users_controller_spec.rb` file

```ruby
# users_controller_spec.rb

describe "#new" do
  it "renders a new template" do
    get :new
    expect(response).to render_template(:new)
  end
  it "assigns a new user variable" do
    get :new
    expect(assigns(:user)).to be_a_new(User)
    #be_a_new(arg) checks the type of the argument passed
  end
end
```

We'll have to modify our `routes.rb` file now:

```ruby
# routes.rb

resources :users, only: [:new, :create]
```

After failing once, we can navigate to `users_controller.rb` and add the method to pass our tests
```ruby
# users_controller.rb

def new
  @user = User.new
end

def create
  render nothing: true
end
```

Moving on to `describe "#create"`:
```ruby
# users_controller_spec.rb

# Note, all tests were copy/pasted from finished file - try each one at a time with the appropriate changes
context "with valid user attributes" do
  def valid_request
    post :create, user: FactoryGirl.attributes_for(:user)
  end

  it "adds a new user record to the database" do
    count_before = User.count
    valid_request
    count_after = User.count
    expect(count_after).to eq(count_before + 1)
    # expect { valid_request }.to change { User.count }.by(1)
    # One-line solution
  end

  it "redirects to the home page" do
    valid_request
    expect(response).to redirect_to(root_path)
    # Don't forget to set your root_path in your routes.rb
  end

  it "sets a flash message" do
    valid_request
    expect(flash[:notice]).to be
  end
end
```

After failing the tests once, make the appropriate changes in our `users_controller.rb`:

```ruby
# users_controller.rb
# create method

user_params = params.require(:user).permit(:first_name, :last_name, :email, :password)
@user = User.create user_params

# Replace 'render nothing: true' with
redirect_to root_path, notice: "account created!"
```

Let's add one more test to check if the user is logged in:
```ruby
# users_controller_spec.rb

it "sets the session user_id with the created user id" do
  valid_request
  expect(session[:user_id]).to eq(User.last.id)
end
```

After failing, move to `users_controller.rb` and add to the `create` method:
```ruby
# users_controller.rb
# create method

session[:user_id] = @user.id
```

Moving onto the tests for *invalid user attributes* now:
```ruby
# users_controller_spec.rb

context "with invalid user attributes" do

  def invalid_request
    post :create, user: FactoryGirl.attributes_for(:user).merge(first_name: nil)
    # Note: Uncomment first_name validation in user.rb to make this test fail once
  end

  it "doesn't add a record to the database" do
    expect { invalid_request }.to change{ User.count }.by(0)
  end

  it "renders the new template" do
    invalid_request
    expect(response).to render_template(:new)
    # Note: Don't forget to create new.html.erb in the views/users folder to make the test pass
  end

end
```

And to make the tests pass we make the changes in `users_controller.rb`
```ruby
# users_controller.rb

def create
  user_params = params.require(:user).permit(:first_name, :last_name, :email, :password)
  # @user = User.create user_params - before invalid testing
  @user = User.new user_params
  if @user.save
    session[:user_id] = @user.id
    redirect_to root_path, notice: "account created!"
  else
    render :new
  end
end
```

Note that we aren't dealing with helper methods in `rspec` for now, so we'll just remove it to prevent unwanted errors
```bash
rm spec/helpers/users_helper_spec.rb
```

## Pledges

We should apply TDD to a sessions controller (not generated yet) but for the sake of time now we'll implement pledges on a campaign. The sessions controller is similar to what we have done already

Begin by creating the pledge model. Note that a user can have many pledges and a campaign can have many pledges

```bash
bin/rails g model pledge amount:float user:references campaign:references
rake db:migrate
```

Now we need to add the `has_many` methods to `user.rb` and `campaign.rb`
```ruby
# user.rb
has_many :pledges, dependent: :nullify

# campaign.rb
has_many :pledges, dependent: :destroy
```

Before writing tests, let's adjust our `pledges.rb` in our `factories`
```ruby
# pledges.rb

FactoryGirl.define do
  factory :pledge do

    association :user, factory: :user
    association :campaign, factory: :campaign

    amount { 1.5 + rand(1000) }
  end
end
```

Let's play with these changes a bit first in `rails c`
```bash
# Create a pledge associated with a user and a campaign
001 > c = Campaign.last
002 > u = FactoryGirl.create(:user)
003 > FactoryGirl.create(:pledge, user: u, campaign: c)
+----+--------+---------+-------------+
| id | amount | user_id | campaign_id |
+----+--------+---------+-------------+
| 1  | 558.5  | 1       | 2           |
+----+--------+---------+-------------+
# Outputs for 001 and 002 have been omitted for spacing
# created_at and updated_at fields have been omitted for spacing
```

Tam's notes on the ways to generate a pledge in `rails c`

```ruby
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
```

Now we can start testing our `pledge_spec.rb` model
```ruby
# pledge_spec.rb

describe "validations" do
  it "requires an amount" do
    p = Pledge.new(FactoryGirl.attributes_for(:pledge).merge({amount: nil}))
    expect(p).to be_invalid
  end
  it "requires an amount 1 or greater" do
    p = Pledge.new(FactoryGirl.attributes_for(:pledge).merge({amount: -1}))
    expect(p).to be_invalid
  end
end
```

Validate as follows in `pledge.rb`
```ruby
# pledge.rb

validates :amount, presence: true, numericality: {greater_than_or_equal_to: 1}
```

We can now move on to writing our tests in our `pledges_controller_spec.rb` file. Once again, go through each test one by one to fail them first before making the appropriate changes (seen in the block after)
```ruby
# pledges_controller_spec.rb

let(:campaign) { FactoryGirl.create(:campaign)}
# We have this to generate a campaign instance so we have an id for our test methods to find
# Recall that let(:arg) is a short form to write:
# def arg
#   @arg ||= FactoryGirl.create(:arg)
# end
let(:user) { FactoryGirl.create(:campaign) }

describe "#new" do

  context "without a signed in user" do
    # To pass this context, we'll need a method to authenticate the user in our ApplicationController
    it "redirects to sign up page" do
      get :new, campaign_id: campaign.id
      # We need to pass a campaign_id or we won't know which campaign the pledge is for
      expect(response).to redirect_to new_user_path
    end
  end

  context "with a signed in user" do
    # We set the session[:user_id] to a valid user id to emulate user being signed in
    before { request.session[:user_id] = user.id }
    it "renders a new template" do
      # Create new.html.erb in views/pledges for this test to pass
      get :new, campaign_id: campaign.id
      expect(response).to render_template(:new)
    end
    it "assigns a new pledge instance variable" do
      get :new, campaign_id: campaign.id
      expect(assigns(:pledge)).to be_a_new(Pledge)
    end
  end

end
```

We also need to make the appropriate changes to our `routes.rb` file:
```rb
# routes.rb

resources :campaigns do
  resources :pledges, only: [:new, :create]
end
```

Now in our `ApplicationController` we make the changes to help pass the "without a signed in user" context
```ruby
# ApplicationController

def authenticate_user!
  redirect_to new_user_path unless user_signed_in?
end

def user_signed_in?
  session[:user_id].present?
end
```

And finally we make the tests pass by making these changes to our `pledges_controller.rb` file:
```ruby
# pledges_controller.rb

before_action :authenticate_user!

def new
  @pledge = Pledge.new
end
```

Finally remove the helper method spec for pledges as we won't be needing them yet.
```bash
rm spec/helpers/pledges_helper_spec.rb
```
