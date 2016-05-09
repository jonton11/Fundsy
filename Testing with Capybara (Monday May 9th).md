## Testing with Capybara (Monday May 9th)
<hr>
For this lecture we will be using our <strong> fundsy </strong> application.

Testing with Capybara implements Behaviour Driven Development (BDD) rather than unit tests or TDD

Capybara emulates/mimics a web browser (clicking links, entering address, form inputs, etc.)

We begin by requiring the <em>quartz</em> library

```bash
brew install qt
```

Now we add the necessary gems
```ruby
# Gemfile in group :development, :test do

gem 'capybara'
gem 'launchy'

# Add simple_form and bootstrap-sass gems as well - we will be styling if necessary for this app
```

Don't forget to `bundle` as well.

While using `capybara`, we try to view our application from a User perspective
- What will the User see when they view page X?
- What will the User be able to do on page X?
- What features are available to the User?

We will begin by doing things called feature tests

```bash
bin/rails g rspec:feature campaigns

# Output of command above - note that this is in the features folder, do not confuse for the file in the model folder
create  spec/features/campaigns_spec.rb

# Also configure simple_form since we're using the gem now

bin/rails generate simple_form:install --bootstrap
# Note that we use bin/rails rather than rails to utilize Spring - this loads rails in the background and is a little faster than simply using rails
```

Now we head over to `spec/features/campaigns_spec.rb` to begin writing our tests.

```ruby
# campaigns_spec.rb

require 'rails_helper'

RSpec.feature "Campaigns", type: :feature do
  describe "Listings Page" do
    it "contains a text: All Campaigns" do
      # Visit is a method from Capybara that emulates visiting a page from RSpec
      visit campaigns_path
      # page is an special object from capybara that we can do matching on - displays as HTML page
      expect(page).to have_text("All Campaigns")
    end
  end
end
```

Now to test in the terminal:
```bash
# Can also specify the line for the test we wish to run
rspec ./spec/features/campaigns_spec.rb
```

Since we have failed, we can head to `index.html.erb` to add the necessary code

```erb
<!-- index.html.erb -->

<h1> All Campaigns </h1>
```

Run the test again to pass.

We can also check more specific areas such as HTML tags

```ruby
# campaigns_spec.rb

it "contains an h2 element with text: Recent Campaigns" do
  visit campaigns_path
  # have_selector here is another matcher
  # note that h2 is in quotes because of the Nokogiri gem - usually we send it as a symbol e.g. :h2
  expect(page).to have_selector "h2", text: "Recent Campaigns"
end
```

Again, run the test to fail, then add the necessary code in the required file.

```erb
<!-- index.html.erb -->

<h2> Recent Campaigns </h2>
```

We can also check attributes pulled from an object - e.g. if we want to check for a title

```ruby
# campaigns_spec.rb

it "displays a campaign's title on the page" do
  c = FactoryGirl.create(:campaign)
  visit campaigns_path
  # Expect somewhere on the page that c.title exists
  expect(page).to have_text(c.title)
end
```

```erb
<!-- index.html.erb -->

<% @campaigns.each do |campaign| %>
<!-- well class here is a bootstrap class -->
  <div class="well">
    <h3><%= campaign.title.capitalize %></h3>
    <hr>
  </div>
<% end %>
```

Note that we may still fail because this is a <em>case-sensitive</em> search. We bypass this by using Regular Expression. Note that there are other ways, but this might be the simple case in this scenario

```ruby
# campaigns_spec.rb

expect(page).to have_text /#{c.title}/i
# We wrap this in RegExp and put 'i' at the end to make it a case-insensitive search
```

Try to be realistic with tests, e.g. don't try every combination of tests scenarios possible, just which ones are likely to happen

These were a few tests for the `index.html.erb` - we'll move to tests for `user_controller.rb` for now.

```bash
bin/rails g rspec:feature user_signup
```

Since Capybara can be slow (due to emulation of browser requests etc.) - we can generate multiple tests at once

```ruby
# user_signups_spec.rb

require 'rails_helper'

RSpec.feature "UserSignups", type: :feature do
  describe "valid user data" do
    it "redirects to the home page, displays the user name and show flash message" do
      visit new_user_path
      valid_attributes = FactoryGirl.attributes_for(:user)
      # fill_in is a Capybara method - must give it some way to identify the input field
      # Either with label (case sensitive) or the id of the input field
      fill_in "First name", with: valid_attributes[:first_name]
      fill_in "Last name", with: valid_attributes[:last_name]
      fill_in "Email", with: valid_attributes[:email]
      fill_in "Password", with: valid_attributes[:password]
      fill_in "Password confirmation", with: valid_attributes[:password]
    end
  end
end
```

```bash
rspec ./spec/features/user_signups_spec.rb
```

Run and fail - likely due to missing label

```erb
 <!-- new.html.erb -->

<%= simple_form_for @user do |f| %>
  <%= f.input :first_name %>
<% end  %>
```

Now the first passes, but the second fails. So let's fix for all of them.

```erb
<!-- new.html.erb -->

<%= f.input :last_name %>
<%= f.input :email %>
<%= f.input :password %>
<%= f.input :password_confirmation %>
```

After testing and success, let's emulate saving and opening a page
```ruby
# user_signups_spec.rb

# using the launchy gem, Capaybara will open up the current page in Chrome for us to examine
save_and_open_page

# valid_attributes and fill_in methods in between

click_button "Sign Up"
```

```erb
<!-- new.html.erb -->

<%= f.submit "Sign Up" %>
```

Now let's actually try testing a method

```ruby
# user_signups_spec.rb

full_name = "#{valid_attributes[:first_name]} #{valid_attributes[:last_name]}"
expect(page).to have_text /#{full_name}/i
```

After failing, lets add the name to our `application.html.erb`. Note that we will have to add the appropriate methods in our `application_controller` for `current_user` etc.

```ruby
# application_controller.rb

def user_signed_in?
  session[:user_id].present?
end
helper_method :user_signed_in?

def current_user
  @current_user ||= User.find session[:user_id] if user_signed_in?
end
helper_method :current_user
```

```erb
<!-- application.html.erb -->

<%= link_to "Home", root_path %>
|
<%= link_to "New Campaign", new_campaign_path %>
<% if user_signed_in? %>
   Hello, <%= current_user.full_name %>
 <% else %>
   <%= link_to "Sign Up", new_user_path %>
 <% end %>
```

Then run the test and we should pass.
