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
