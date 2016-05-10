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
