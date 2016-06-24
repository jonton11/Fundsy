## OAuth with Twitter for Rails with OmniAuth (Wednesday, May 11 Lecture)
<hr>

We will be using <em> fundsy </em> for the OAuth lecture.

OAuth: Open Authentication

The idea is that a user is already authenticated in applications like Facebook, Twitter, Github, etc. We'll be looking at how to integrate features such as "Sign In with Facebook" or "Sign In with Google" etc.

Clicking the feature takes you to Facebook where a user can accept or decline access. Facebook gives a token that links back to our application which will authenticate a user.

Before integrating this feature, a developer must decide if they want the User to sign up with a username and password, or to sign up with Twitter, or possibly both.

Assumptions: Our Application has the `has_secure_password` feature and you have Twitter credentials (if not you must sign up for a Twitter account).
<hr>
### Twitter Credentials

- Visit https://apps.twitter.com
- Click `Create New App`
- Give your app a name and description
- Website will be `http://127.0.0.1:3000/` and the callback URL will be `http://127.0.0.1:3000/callbacks/twitter`
  - Note that the domain we use our IP address as a workaround as Twitter does not allow `localhost`
- Head to permissions and take a note of what permissions are allowed by Twitter. Check the second radio button (Read and Write)

We'll rename our `secrets.yml` to `secrets.yml.example` and add `/config/secrets.yml` to our `.gitignore` file
```ruby
# .gitignore

# Ignore bundler config.
/.bundle
/config/secrets.yml
```

Now duplicate `secrets.yml.example` and name it `secrets.yml`. This is for backup as well as if anyone wants to look at how we implemented something there is a reference.

- Store your `Consumer Key (API Key)` as well as the `Consumer Secret (API Secret)` in `secrets.yml`

```ruby
# config/secrets.yml

development:
  secret_key_base: 3cf0654de8e0d10a482a9981216812ed12a3be2e14058664b987ed84c870f3a...
  twitter_consumer_key: XXXXX
  twitter_consumer_secret: YYYYY
```

<hr>
Begin by adding the gem `omniauth-twitter` to `Gemfile`
```ruby
# Gemfile

gem 'omniauth-twitter'

# Don't forget to bundle after
```

Now create a file in `initializers` called `omniauth_setup.rb`. From the Omniauth Github, we'll copy the setup code to include our secrets. You can check if your keys are defined in the rails console.

```bash
# bin/rails c

Rails.application.secrets.twitter_consumer_key
Rails.application.secrets.twitter_consumer_secret
```

```ruby
# omniauth_setup.rb

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Rails.application.secrets.twitter_consumer_key,
                     Rails.application.secrets.twitter_consumer_secret
end
```

Now we need to set up the routes necessary for redirecting to Twitter.

```ruby
# routes.rb

get '/auth/twitter', as: :sign_in_with_twitter
get '/auth/twitter/callback' => 'callbacks#twitter'
```

Then we need to implement a Sign In feature.

```erb
<!-- application.html.erb -->

<%= link_to 'Sign In With Twitter', sign_in_with_twitter_path %>
```

Now start the rails server `bin/rails s` and click the new link to be redirected to Twitter.

Let's generate a controller to handle the callback feature.

```bash
# terminal

bin/rails g controller callbacks
```

Now head to the controller and add the `twitter` method
```ruby
# callbacks_controller.rb

class CallbacksController < ApplicationController # :nodoc:
  def twitter
    render json: request.env['omniauth.auth']
    # Let's inspect what information is returned - this will be a hash
  end
end
```

Let's add the OAuth fields to our user model now.

```bash
# terminal

  bin/rails g migration add_oauth_fields_to_users uid provider twitter_token twitter_secret twitter_raw_data:text
```

Let's head to the migration file and decide what we need to index

```ruby
# migration file

class AddOauthFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uid, :string
    add_column :users, :provider, :string
    add_column :users, :twitter_token, :string
    add_column :users, :twitter_secret, :string
    add_column :users, :twitter_raw_data, :text

    add_index :users, [:uid, :provider]
    # Composite index
  end
end

# bin/rake db:migrate in terminal after
```

Now let's add to our callback controller
```ruby
# callbacks_controller.rb

def twitter
  user = User.find_or_create_with_twitter request.env['omniauth.auth']
  session[:user_id] = user.id
  redirect_to root_path, notice: 'Thank you for signing in with Twitter'
  # render json: request.env['omniauth.auth']
end
```

And now we have to define the `find_or_create_with_twitter` method.
```ruby
# user.rb - public method

def self.find_or_create_with_twitter(omniauth_data)
  user = User.where(provider: 'twitter', uid: omniauth_data['uid']).first
  # We need .first here because it is an array - we simply want the first one
  unless user
    full_name = omniauth_data['info']['name']
    user = User.create(first_name: full_name[0..full_name.rindex(' ')-1],
                       last_name: full_name.split.last,
                       provider: 'twitter',
                       uid: omniauth_data['uid'],
                       password: SecureRandom.hex(16),
                       twitter_token: omniauth_data['credentials']['token'],
                       twitter_secret: omniauth_data['credentials']['secret'],
                       twitter_raw_data: omniauth_data)
    # first_name: is parsed by using .rindex - play with this in console to see
    # password is unnecessary for now - you can change this later. For now we'll use SecureRandom.hex(16)
    # Grab the twitter data from schema.rb
  end
  user
end
```

Notice that our email validation now may pose issues. Two blank emails also fails the uniqueness validation. We will need <em> conditional validations </em>

```ruby
# user.rb

validates :email, presence: true, uniqueness: true, unless: :with_oauth?

def with_oauth?
  provider.present? && uid.present?
end
# Will only kick the uniqueness and presence validation if this method returns true
```

We also want to store the Twitter raw data for our User model

```ruby
# user.rb

serialize :twitter_raw_data, Hash
# serialize the Twitter as a Hash - in the database there is no way to store
# Hashes (they are text or blobs) so we'll use a method from serialize
```

ASIDE: Now the * won't appear on our Sign Up page as the validation has been removed, simply add `require: true` in the input line for the `new.html.erb` page
```erb
<!-- users/new.html.erb -->

<%= f.input :email, require: true %>
```

Notice our code is awfully long, let's refactor.

```ruby
# user.rb - private method

# Change name extraction into if/else in the case that the user signs up on Twitter with only one name

def self.extract_first_name(full_name)
  if full_name.rindex(" ")
    full_name[0..full_name.rindex(" ") - 1]
  else
    full_name.split.first
  end
end

def self.extract_last_name(full_name)
  if full_name.rindex(' ')
    full_name.split.last
  else
    ''
  end
end

# Don't forget to change validations

validates :first_name, presence: true
validates :last_name, presence: true, unless :with_oauth?

# And finally replace in the code.
first_name: extract_first_name(full_name)
last_name: extract_last_name(full_name)
```

Let's integrate the feature to tweet on behalf of the user. Begin by installing the `twitter` gem

```ruby
# Gemfile

require 'twitter'

# bundle in terminal
```

We need to create a client object for the Twitter gem that takes in consumer key and consumer secret. Refer to the Twitter gem on Github for more information. For now we'll simply insert the code in `User.rb` to test it out.

```ruby
# user.rb - private method

user = User.last
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = Rails.application.secrets.twitter_consumer_key
  config.consumer_secret     = Rails.application.secrets.twitter_consumer_key
  config.access_token        = user.twitter_token # from user
  config.access_token_secret = user.twitter_secret # from user
end
```

```bash
# bin/rails c - test to see the methods working

client.follow("internethostage")
client.update("@internethostage Hello Cristian")
# Head back to your Twitter and you will see that you followed and tweeted
```

## Debugging Tips
<hr>
Skipped for the interest of time => Check out the presentation for notes.

Push the Blog application for Peer Review
```bash
# Comments for peer review of Blog

git clone [git_project]
git checkout -b code_review
git checkout master
git log
# Grab the shaw of the very first commit (key)
# Make a copy of your code now --> Damages might appear
git reset (key)
git checkout code_review
git push -u origin code_review
git checkout master
git push -f origin master
# After merging the branch on Github
# Review the single commit via Github
git fetch
# Get the latest from Github
git reset origin/master --hard
# Reset your master to the master that was fetched from Github
```

## NoSQL
<hr>

NoSQL (or "Not Only" SQL) is an umbrella term systems that use storage and retrieval of data that doesn't use relational tables.

Refer to slides (a lot of history etc.) => NoSQL is also very useful for Big Data applications, realtime applications (Twitter etc.)

Refer to https://github.com/lastobelus/mongodb-crud/wiki for the walkthrough.
```bash
# terminal

# Install MongoDB
brew install mongodb

# Run MongoDB in the background
# & at the end will simply run the program in the background without the need to open a new tab
mongod --config /usr/local/etc/mongod.conf &

# Generate a new Rails app without ActiveRecord
# ActiveRecord is SQL oriented so we want to skip this
rails new mongodb-crud --skip-active-record
```

Now in our `Gemfile` let's add the necessary gems as well as Bootstrap
```ruby
# Gemfile

# Gem to help connect to MongoDB
gem 'mongoid', '~> 5.1.0'
gem 'bootstrap-sass', '~> 3.3.6'
gem 'bootstrap-generators', '~> 3.3.4'
#
```

Now configure the files for Bootstrap:

```js
// application.js

//= require bootstrap-sprockets
```

```ruby
# rename application.css to application.scss

@import "bootstrap-variables";
@import "bootstrap-sprockets";
@import "bootstrap";
@import "bootstrap-generators";
```

Back to our setup:

```bash
# terminal

bundle install
rails g mongoid:config

bundle
# Generator creates templates for when we use the scaffolder
rails generate bootstrap:install --stylesheet-engine=scss

# create the CRUD --> R U SRS RN
rails g scaffold student first_name last_name email
```

Now a few changes in our `Ruby` files - we'll make validations here to prevent 3rd party ActiveRecord validations
```ruby
# routes.rb

root 'students#index'

# student.rb

include Mongoid::Document
field :first_name, type: String
field :last_name, type: String
field :email, type: String

validates :first_name, :last_name, presence: true
validates :email, presence: true, uniqueness: true

# In Mongo, we define indexes in the model
# However, simply defining it doesn't mean it's there. We need to run a rake job
# to implement it fully. Unlike Rails, it has better integration for uniqueness
index({ email: 1 }, { unique: true })
```

And finally in the terminal
```bash
# terminal

rake db:mongoid:create_indexes
```

When do we choose to use NoSQL over PostgreSQL?

Unfortunately, it depends.
- If relationships between data types are important => development will be easier with PostgreSQL.
- Example: A store => {product, line_items, order} => PostgreSQL (but may have to change to scale when your app grows)
- Note that key-value storage will have much better performance.
- Fan-out => when data needs to go to a lot of areas (e.g. Justin Bieber tweeting to 25m people) - RMDBS will not accomplish this so a combination may be needed
- NoSQL tends to have more development overhead (no need for schema...but this may be counterintuitive)

If you're unsure of what your schema would be => store data as JSON in Postgres until you need more structure
