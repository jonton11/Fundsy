## JSON API (Tuesday May 10th)
<hr>

For this lecture we will be referring back to our <em> fundsy </em> app once again.

To review, let's grab our campaigns as a JSON object.

```ruby
# campaigns_controller.rb - let's begin by rendering all the campaigns in JSON

def index
  @campaigns = Campaign.order(:created_at)
  respond_to do |format|
    format.json { render json: @campaigns }
    # note that render json: will automatically call .to_json method to the argument passed
    format.html { render }
  end
end
```

Begin by creating a new folder in our `controllers` folder called `api`. This folder will contain all of our API.

Note that this for consistent naming and organization so we don't have to create controllers such as `api_campaigns_controller.rb` (this could get very messy down the line). Not only that, it also makes it easier to control permissions as well as version control.

Next let's add a folder in `api` called `v1`. We will now create a campaigns controller within `v1`.

```bash
bin/rails g controller api/v1/campaigns
# simply put the path where we wish the controller to be generated
```

Note that after creating, there are a lot of files we don't need (`.coffee`, `css` etc.). It's good practice to get into the habit of manually creating the files we need. For now we'll remove the unnecessary files - (spec_helpers, .coffee, .css - we will only be using the `campaigns_controller.rb` file for now)

```ruby
# campaigns_controller.rb - controllers/api/v1

def index
  @campaigns = Campaign.order(:created_at)
  render json: @campaigns
end
```

To create the correct routes to access this folder, we use `namespacing` in our `routes.rb`.

```ruby
# routes.rb

namespace :api do
  namespace :v1 do
    resources :campaigns
  end
end
```

ASIDE: If we were to make another version, simply make another folder (e.g. `v2`) in the `api` folder.

```ruby
# campaigns_controller - controllers/api/v2

class Api::V2::CampaignsController < Api::V1::CampaignsController
# This will now inherit from v1
# def create => any methods we write here will overrwrite
end
```

To give the default output to be in JSON, we can set the default as such. Route example default to JSON

```ruby
# routes.rb

namespace :api, defaults: { format: :json } do
  namespace :v1 do
    resources :campaigns
  end
  namespace :v2 do
    resources :campaigns
  end
  # This is how we would set paths to the second version
end
```

Let's add user references to our campaigns to begin with.
```bash
# terminal

bin/rails g migration add_user_references_to_campaigns user:references
bin/rake db:migrate
```

Now add the necessary `belongs_to` and `has_many` in our models.
```ruby
# Campaign.rb
belongs_to :user

# User.rb
has_many :campaigns, dependent: :nullify
```

JBuilder is a templating system, similar to `erb` where we can use `JBuilder` to generate `HTML`. This is added in our `Gemfile` by default.

Begin by heading to `api/v1/campaigns_controller.rb` and comment out the `render json:` line.

```ruby
# campaigns_controller.rb - api/v1/campaigns_controller.rb

def index
  @campaigns = Campaign.order(:created_at)
  # this will render /api/v1/views/index.json.jbuilder
  # render json: @campaigns
end
```

Now let's head to our `vies/api/v1/campaigns` folder and create the file `index.json.jbuilder`

```jbuilder
<!-- index.json.jbuilder -->

json.array! @campaigns do |campaign|
  json.title campaign.title.titleize
end
<!-- json.array! here means we want to send the data back as an array -->
<!-- json.campaigns will return a hash with key campaigns and value of titles -->
```

We can render numbers or URLs the same way we render something else

```jbuilder
<!-- index.json.jbuilder -->

json.array! @campaigns do |campaign|
  json.id       campaign.id
  json.title    campaign.title.titleize
  json.url      campaign_url(campaign)
  json.api_url  api_v1_campaign_url(campaign)
  <!-- Note, try to use an actual URL rather than the path -->
end
```

We can also pass in our own `helper_methods`.

```ruby
# application_helper.rb

module ApplicationHelper
  def formatted_date(date)
    date.strftime('%Y-%b-%d') if date
  end
end
```

Now back in our `jbuilder` file

```jbuilder
<!-- index.json.jbuilder -->

json.created_on formatted_date(campaign.created_at)
json.end_date   formatted_date(campaign.end_date)
```

Recall that JBuilder utilizes view files that have access to attributes like URL, formatted date by default (or through helper_methods). Another approach could be using Serializer.

Another approach could be to use ActiveModel Serializer. Serializer is a class that when we `render :json` - a serializer will be picked up by default, removing the need for a separate view file.

We first build a Serializer class that will automatically render to JSON.
```ruby
# Gemfile

gem 'active_model_serializers'
```

```bash
# terminal

bin/rails g serializer campaign
# naming convention is to keep as singular as the serializers are linked to the models
```

Now let's see it in action.

```ruby
# campaigns_controller - api/v1/campaigns_controller

def show
  campaign = Campaign.find params[:id]
  render json: campaign
end
```

```ruby
# campaign_serializer.rb

class CampaignSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  def title
    object.title.titleize
    # This will titleize the title attribute in the returned JSON object
  end
end
```

We can pass methods in this file to grab other attributes that may not be in our model (e.g. url). We can test this by checking a campaign, e.g. `localhost:3000/api/v1/campaigns/1`. The downside of this is that we don't have access to all the helper_methods in our model - we will need to include ApplicationHelper.

```ruby
# campaign_serializer.rb

class CampaignSerializer < ActiveModel::Serializer # :nodoc:
  attributes :id, :title, :body, :url, :created_at
  has_many :pledges

  include ApplicationHelper

  def title
    object.title.titleize
    # This will titleize the title attribute in the returned JSON object
  end

  def url
    campaign_url(object, host: 'http://localhost:3000')
  end

  def created_at
    formatted_date(object.created_at)
  end
end
```

Notice that pledges will show up as `[]`. Let's quickly generate one in the Rails console.
```bash
# terminal

bin/rails c

# rails c

c = Campaign.find 1
c.pledges.create(amount: 5, user: User.last)
c.save
```

Now we can view the pledge. Notice that the format displayed will be default JSON. To format the way it's displayed, we can generate another serializer for pledges.
```bash
# terminal

bin/rails g serializer pledge
```

Now moving to the generated serializer file

```ruby
# pledge_serializer.rb

class PledgeSerializer < ActiveModel::Serializer # :nodoc:
  attributes :id, :amount, :user_name

  def user_name
    object.user.full_name.titleize if object.user
  end
end
```

Let's now talk about <em>securing API</em>. How do we store the API key? We can possibly use an app_key file or simply store it in the User model. Let's store it in the User model.

```bash
# terminal

bin/rails g migration add_api_key_to_users api_key
```

Note that an API keys behaves a lot like an id. As we will be doing a lot of finding for these keys, let's index them.
```ruby
# migration file that we just generated

class AddApiKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_key, :string

    add_index :users, :api_key, unique: true
  end
end
```

Now let's head to our User model

```ruby
# user.rb

before_create :generate_api_key

private

def generate_api_key
  begin
    self.api_key = SecureRandom.hex(32)
    # Recall that we use self here to reference the object (instance variable)
    # rather than the class. When we are setting a variable we use self. but
    # reading a variable it becomes redundant.
  end while User.exists?(api_key: api_key)
end
```

We can test this in the Rails console.

```bash
# terminal

bin/rails c

User.create(first_name: "Jon", last_name: "Wong", email: "jon@jonton.com", password: "supersecret", password_confirmation: "supersecret")

# Output - created_at, updated_at fields omitted for spacing
+----+------------+-----------+----------------+------------------+--------------------+
| id | first_name | last_name | email          | password_digest  | api_key            |
+----+------------+-----------+----------------+------------------+--------------------+
| 2  | Jon        | Wong      | jon@jonton.com | $2a$10$d61Xmw... | ea78610769a2fc3... |
+----+------------+-----------+----------------+------------------+--------------------+

# For the other users

u = User.find x # Where x is a number
u.first_name
u.send(:first_name)
u.send(:generate_api_key)
u.save
```

Now to create authentication, head back to the campaigns_controller.rb and create the method
```ruby
# campaigns_controller.rb - api/v1

before_action :authenticate_user

private

def authenticate_user
  def authenticate_user
    @user = User.find_by_api_key params[:api_key]
    # We can't redirect but we can send a different HTTP code
    head :forbidden unless @user
  end
end
```

Now try to access the the campaigns for the User and we will be given a forbidden page.

Head to rails console and grab the necessary api key for that user.

```bash
# rails console

# For example we will use User with id = 2
u = User.find 2
u.api_key
# copy the key
```

In the URL, append ?api_key=(api_key) with no brackets. Make sure it corresponds with the correct User ID.
```
http://localhost:3000/campaigns/1 --> http://localhost:3000/campaigns/1?api_key=(api_key)
```

Now let's refactor a bit. Let's begin by making a file in our `api` folder called `base_controller.rb`

```ruby
# base_controller.rb

class Api::BaseController < ApplicationController
  before_action :authenticate_user

  private

  def authenticate_user
    @user = User.find_by_api_key params[:api_key]
    head :forbidden unless @user
  end
end
```

Because of this, we can remove these methods in our `campaigns_controller.rb`. Notice that now we must change which file it inherits from to our `BaseController`. While we're in this file let's also add our `create` and `campaign_params` methods for the next part.
```ruby
# campaigns_controller - api/v1

class Api::V1::CampaignsController < Api::BaseController
  def create
    campaign = Campaign.new(campaign_params)
    if campaign.save
      render json: campaign
      # Don't need instance variable here
    else
      render json: { errors: campaign.errors.full_messages }
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:title, :body, :goal, :end_date)
  end
end
```

Note that we can also curl (link) in our console to view the output. We can also use the Postman app.

```bash
curl # link here
```

However, when using the Postman app we may get forbidden errors due to cross-site scripting. Rails actually does this for us with `protect_from_forgery`. Let's head to our BaseController to amend this.

```ruby
# base_controller.rb

class Api::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  # Null session takes all the session data and makes it null. This is fine
  # in this scenario because we aren't depending on the session here, only the API key.
  before_action :authenticate_user

  private

  def authenticate_user
    @user = User.find_by_api_key params[:api_key]
    head :forbidden unless @user
  end
end
```

Testing again and the Postman request should go through.

ASIDE: Testing the `faraday` gem. Let's create a separate file for this. First, install the faraday gem

```bash
# terminal

gem install faraday
```

Now make the file as follows:
```ruby
# fundsy_ruby_client.rb

require "faraday"
require "json"

BASE_URL = "http://localhost:3000/"

conn = Faraday.new(url: BASE_URL) do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

response = conn.get (add the rest of the url here)
# puts response.body
# Notice that response.body returns an array of hashes

campaigns = JSON.parse(response.body)

# Print the titles
campaigns.each do |campaign|
  puts campaign["title"]
end
```

Testing APIs with RSpec

Go to Postman, type in parameters 1 by 1, look at JSON etc.

We will write tests for the campaigns controller (index and show)

Begin by writing tests in spec/controllers/api/v1/campaigns_controller_spec.rb
```ruby
require 'rails_helper'

RSpec.describe Api::V1::CampaignsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  # No need to generate API key here anymore because it will be generated when the user is created
  render_views
  # We need to render_views first. By default, Controller Specs don't render views (for speed and separation purposes)
  # In here we need to have the controller spec render views because for the
  # index action we're using jBuilder which is a view to render JSON
  let(:campaign) { FactoryGirl.create(:campaign) }
  # Generate a campaign
  describe '#index' do
    context 'with no API key' do
      it 'responds with a 403 HTTP status code' do
        get :index
        expect(response.status).to eq(403)
        # Test for forbidden error
      end
    end
    context 'with API key' do
      it 'renders the campaigns title in the JSON response' do
        campaign
        get :index, api_key: user.api_key, format: :json
        expect(response.body).to have_text /#{campaign.title.titleize}/i
        puts '>>>>>>>>>>>>>'
        puts response.body
        puts response.status
        puts '>>>>>>>>>>>>>'
      end
    end
  end
  describe '#show' do
    context 'with api_key provided' do
      it 'renders a JSON with a campaign title' do
        get :show, id: campaign.id, format: :json, api_key: user.api_key
        response_body = JSON.parse(response.body)
        expect(response_body['campaign']['title']).to eq(campaign.title.titleize)
      end
    end
  end
end
```

## Advanced Javascript
<hr>
<em> this </em> references an object depending on the context.

This refers to the global context. In the console, calling `this` will simply return the window. Think of `this` as referencing "one step above".

We will be examining `this` in object constructors with a file called `cookie.js` and testing in browser console.

```js
// cookie.js

var Cookie = function(sugar, flour) {
  // mimic a class by setting the variable in upper case

  // this references the object about to get created
  this.sugar = sugar;
  this.flour = flour;

  this.calories = function() {
    // var that = this;
    var details = function(unit) {
      console.log(this);
      // this here will reference window --> no references to sugar or flour in this.calories function
      // We can get around this by using 'that' --> uncomment to see the difference
      console.log("This cookie has " + this.sugar + unit + "g of sugar");
      console.log("This cookie has " + this.flour + unit + "g of flour");
      // console.log("This cookie has " + that.sugar + unit + "g of sugar");
      // console.log("This cookie has " + that.flour + unit + "g of flour");
    }
    details();
    // When using '.call' you tell the function what 'this' should be inside
    // Which will be the first argument of you the 'call' function
    details.call({sugar: 55, flour: 66}, "g");
    details.call(this, "g");
    details.apply(this, ["g"]);
    return this.sugar * 3.8 + this.flour * 3.5;
  } // defining a method function
}

var c  = new Cookie(10, 15); // {sugar: 10, flour: 15}
var c1 = new Cookie(12, 16); // {sugar: 12, flour: 16}

// Aside example to show method function
var cookie = {
  sugar: 10,
  flour: 15,
  calories: function() {
    return this.sugar * 3.8 + this.flour * 3.5;
  } // calories here is a method function
}
```

Accessing DOM with `this`. We'll test examples in a new file called `dom.js`

```js
// dom.js

var links = document.getElementsByTagName("a");

for (var i = 0; i < links.length; i++) {
  var element = links[i];
  element.style.color = "red";
}

// Above is equivalent to $('a').css("color", "red");
```

Let's try using `this`

```js
// dom.js
var links = document.getElementsByTagName("a");

for (var i = 0; i < links.length; i++) {
  var element = links[i];
  element.addEventListener("click", function(event)) {
    event.preventDefault();
    this.style.color = "red";
  }
}
```

Using .bind we can control `this`

```js
// cookie.js using .bind(this)

this.calories = function() {
  var details = function(unit) {
    console.log(">>>>>>>>>>>>>");
    console.log(this);
    console.log(">>>>>>>>>>>>>");
    console.log("This cookie has " + this.sugar + unit + "g of sugar");
    console.log("This cookie has " + this.flour + unit + "g of flour");
  }.bind(this); // 'this' inside the function will be the same as 'this' outside it
  details();
  return this.sugar * 3.8 + this.flour * 3.5;
  } // defining a method function
}
```

Chuck Norris example:
```js
// chucknorris.js

// Making a GET request to https://advanced-js.herokuapp.com/chuck_norris which returns a JSON response like:

{  "fact": "Chuck Norris rewrote the Google search engine from scratch."  }

// Write some JavaScript code that does the following:

var chuck = new ChuckNorris(); // this should fetch fact from server
chuck.fetchFact();             // and print the fact to the console
chuck.lastFact;                // this should have the value of the last fact

var ChuckNorris = function() {
  var lastFact = "";
  this.fetchFact = function() {
    $.get("https://advanced-js.herokuapp.com/chuck_norris", function(result) {
      this.lastFact = result.fact
      console.log(result.fact);
    }.bind(this));
  };
};


var chuck = new ChuckNorris();
chuck.lastFact
chuck.fetchFact();
```
