## More on Background Jobs

We'll be using the `redis` gem and database.

```bash
# terminal

brew install redis

# to start the redis server in the Background

redis-server

# in irb

require 'redis'
redis = Redis.new
redis.set("greeting", "Hello World!")
redis.get("greeting")
=> Hello World!

# Redis is essentially a giant hash
```

Let's put the redis gem in our `fundsy application`

```ruby
# Gemfile

gem 'redis'
gem 'sidekiq'
# bundle in terminal
```

We'll also use the help of the `sidekiq` gem

```ruby
# application.rb

config.active_job.queue_adapter = :sidekiq
# This is similar to adding delayed_job in our AwesomeAnswers app
```

We'll created a dedicated class to help with our background jobs

```bash
# terminal => note that job is already a generator provided by Rails

bin/rails g job campaign_goal
```

Now checking the file generated

```ruby
# campaign_goal_job.rb

class CampaignGoalJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # Do something later
    campaign = args[0]
    # Anything we can do at the SQL level we should do first (aggregate, sum etc. because it will be faster)
    # We can use the .sum() method to grab the sum of pledge values at the SQL level
    pledges_amount = campaign.pledges.sum(:amount)
    if pledges_amount >= campaign.goal
      Rails.logger.info ">>>>>>> Campaign Funded"
    else
      Rails.logger.info ">>>>>>> Campaign UnFunded"
    end
  end
end
```

Then to run it in our controller

```ruby
# campaign_controller.rb

if @campaign.save
  CampaignGoalJob.perform_later(@campaign)
  # other code here - we just want to test if it works
  # we can add the method set() to run at a later date
  # e.g. CampaignGoalJob.set(wait_until: @campaign.end_date).perform_later(@campaign)
```

We can check by creating a campaign and then using a Redis GUI to see if it has been placed inside a scheduled folder.

`bin/rails g job send_campaign_summary`

Generate a rake task

```bash
# terminal

bin/rails g task send_summaries
```
