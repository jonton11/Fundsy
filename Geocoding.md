# Geocoding and Maps
<hr>

We will be using our fundsy application for this.

Every campaign must have a address and a pin on the map.

Every user is created with an address so we can display nearby campaigns.

We will be using two gems for this. `Geocoder` and `GMap4Rails`

Google is the best one to use (according to Tam).

Begin by adding the `geocoder` gem to our `Gemfile` and then bundle.
```ruby
# Gemfile

gem 'geocoder'
```

We need to add fields that will let us use geocoding.

```bash
# terminal

bin/rails g migration add_geocoding_fields_to_campaigns address longitude:float latitude:float

bin/rake db:migrate
```

Ideally we'd use geocode in a <em>Delayed Job</em> since we don't always need it (background job). We don't want to be dependent on this.

Head to the campaign model
```ruby
# campaign.rb

geocoded_by :address
# geocoded_by is a method that will automatically look for longitude and latitude
after_validation :geocode
# these methods are coming from the geocoder gem
```

Since our `fundsy` application only has tests, let's create a view for a new campaign. Make sure you have bootstrap.

```erb
<!-- new.html.erb -->

<h1> New Campaign </h1>

<%= simple_form_for @campaign do |camp| %>
  <%= camp.input :title %>
  <%= camp.input :body %>
  <%= camp.input :goal, as: :string%>
  <%= camp.input :end_date %>
  <%= camp.input :address %>
  <%= camp.submit %>
<% end %>
```

We also need to permit the parameters

```ruby
# campaigns_controller.rb

def campaign_params
  params.require(:campaign).permit(:title, :body, :goal, :end_date, :address)
end
```

Now notice in the terminal that when the address is given, the `geocoder` gem will access the longitude and latitude

However, if we use IP address we can access the location without asking for permission.

Let's create the show page and display the map.
```ruby
# show.html.erb
<h1><%= @campaign.title %></h1>
<p>  <%= @campaign.body %></p>
<p>  <%= number_to_currency(@campaign.goal) %></p>
<p>  End Date: <%= formatted_date(@campaign.end_date) %></p>

<div style='width: 800px;'>
  <div id="map" style='width: 800px; height: 400px;'></div>
</div>
```

Then insert google scripts in your `application.html.erb`. Typically we want this before our code, in the header.

```ruby
# application.html.erb

<script src="//maps.google.com/maps/api/js?v=3.23&sensor=false&client=&key=&libraries=geometry&language=&hl=&region="></script>
<script src="//cdn.rawgit.com/mahnunchik/markerclustererplus/master/dist/markerclusterer.min.js"></script>
<script src='//cdn.rawgit.com/printercu/google-maps-utility-library-v3-read-only/master/infobox/src/infobox_packed.js' type='text/javascript'></script> <!-- only if you need custom infoboxes -->
```

Now we need the underscore library to assist with the assets pipeline.

```ruby
# Gemfile

gem 'underscore-rails'
```

Then in our `application.js`

```js
//= require underscore
//= require gmaps/google

// just before require_tree .
```

Now we need some Javascript code to add the pins on our show page.

```erb
<!-- show.html.erb -->

<h1><%= @campaign.title %></h1>
<p><%= @campaign.body %></p>
<p><%= number_to_currency(@campaign.goal) %></p>
<p>End Date: <%= formatted_date(@campaign.end_date) %></p>

<div style='width: 800px;'>
  <div id="map" style='width: 800px; height: 400px;'></div>
</div>

<script>
  handler = Gmaps.build('Google');
  handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
  markers = handler.addMarkers([
    {
      "lat": <%= @campaign.latitude %>,
      "lng": <%= @campaign.longitude %>,
      "infowindow": "<%= @campaign.title %>"
    }
  ]);
  handler.bounds.extendWith(markers);
  handler.fitMapToBounds();
  handler.getMap().setZoom(17);
  });
</script>
```

We want to implement multiple pins on one map as well as for the User. Let's start with User.

```bash
# terminal

bin/rails g migration add_geocoding_fields_to_users address longitude:float latitude:float
```

Now we need the same codes in our `user.rb`

```ruby
# user.rb

geocoded_by :address
after_validation :geocode
```

Let's now create a controller to control showing nearby_campaigns
```bash
# terminal

bin/rails g controller nearby_campaigns
```

Then in our routes
```ruby
# routes.rb

resources :nearby_campaigns, only: [:index]
```

```ruby
# nearby_campaigns.rb

before_action :authenticate_user!

def index
  coordinates = [current_user.latitude, current_user.longitude]
  @campaigns = Campaign.near(coordinates, 40, units: :km)
  # Does a search of everything nearby in a 40km range via geocode gem
end
```

Then with the file Tam gave to us in slack, copy and paste that into `seeds.rb` and create with FactoryGirl

```ruby
# seeds.rb

addresses.each do |address|
  FactoryGirl.create(:campaign, address: address)
end
# bin/rake db:seeds
```

Amend `application.html.erb`
```erb
<% if user_signed_in? %>
|
<%= link_to "Nearby Campaigns", nearby_campaigns_path %>
```

Then to display
```erb
<!-- nearby_campaigns/index.html.erb -->

<% @campaigns.each do |campaign| %>
  <%= campaign.title %> | <%= campaign.address %>
<% end  %>
```

And finally in our Users controller
```ruby
# users_cotroller.rb

user_params = params.require(:user).permit(:first_name, :last_name, :email, :password, :address)
```

As well as our sign up page
```erb
<!-- user/new.html.erb -->

<%= simple_form_for @user do |f| %>
  <%= f.input :first_name %>
  <%= f.input :last_name %>
  <%= f.input :email, require: true %>
  <%= f.input :address %>
  <%= f.input :password %>
  <%= f.input :password_confirmation %>
  <%= f.submit "Sign Up" %>
<% end  %>
```

Let's get a page for our map to display all nearby pins

```erb
<!-- nearby_campaigns/index.html.erb -->

<div>
  <div id="map" style='width: 800px; height: 400px;'></div>
</div>

<script>
  handler = Gmaps.build('Google');
  handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
  markers = handler.addMarkers(<%=raw @markers.to_json %>);
  handler.bounds.extendWith(markers);
  handler.fitMapToBounds();
  // handler.getMap().setZoom(17);
  });
 </script>
```
