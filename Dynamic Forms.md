## Dynamic Form (Friday, May 20th)
<hr>

We will be using our <em> fundsy </em> application for this lecture.

What if we wanted to give different <em> kinds </em> of rewards for campaigns?

Let's look at a campaign
=> Create campaign
=> Decide rewards after

But sometimes we want to define the rewards while creating the campaign. Begin by creating the reward model e.g. creating a campaign also creates rewards dynamically

```bash
# terminal

bin/rails g model reward amount:integer description:text campaign:references
# bin/rake db:migrate
```

Then in `reward.rb`

```ruby
# reward.rb

validates :amount, presence: true, numericality: { greater_than: 0 }
validates :description, presence: true
```

And in our `campaign.rb`
```ruby
# campaign.rb

has_many :rewards, dependent: :destroy
accepts_nested_attributes_for :rewards, reject_if: :all_blank
```

Then in our `campaigns_controller.rb`
```ruby
# campaign_controller.rb

3.times { @campaign.rewards.build }
# This will build campaign rewards * 3
```

```erb


<%= camp.simple_fields_for :rewards do |reward| %>
  <%= reward.input :amount %>
  <%= reward.input :description %>
  <hr />
<% end %>
```

follow tam's commit gg

## Finite State Machines

Sometimes our project or idea takes into several states

aasm stuff

`users = User.all`
`Campaign.all.each {|c| c.update(user: users.sample) }`
