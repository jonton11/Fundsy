## OAuth with Twitter for Rails with OmniAuth (Wednesday, May 11 Lecture)
<hr>

We will be using <em> fundsy </em> for the OAuth lecture.

OAuth: Open Authentication

The idea is that a user is already authenticated in applications like Facebook, Twitter, Github, etc. We'll be looking at how to integrate features such as "Sign In with Facebook" or "Sign In with Google" etc.

Clicking the feature takes you to Facebook where a user can accept or decline access. Facebook gives a token that links back to our application which will authenticate a user.

Before integrating this feature, a developer must decide if they want the User to sign up with a username and password, or to sign up with Twitter, or possibly both.

Assumptions: Our Application has the `has_secure_password` feature and you have Twitter credentials (if not you must sign up for a Twitter account).
<hr>
ASIDE: Twitter Credentials

- Visit https://apps.twitter.com
- Click `Create New App`
- Give your app a name and description
- Website will be `http://127.0.0.1:3000/` and the callback URL will be `http://127.0.0.1:3000/callbacks/twitter`
  - Note that the domain we use our IP address as a workaround as Twitter does not allow `localhost`
- Head to permissions and take a note of what permissions are allowed by Twitter

We'll rename our `secrets.yml` to `secrets.yml.example` and add `/config/secrets.yml` to our `.gitignore` file
```ruby
# .gitignore

# Ignore bundler config.
/.bundle
/config/secrets.yml
```

- Create a file in your config folder called `secrets.yml` and store your `Consumer Key (API Key)` as well as the `Consumer Secret (API Secret)`

```ruby
# config/secrets.yml

development:
  secret_key_base: 3cf0654de8e0d10a482a9981216812ed12a3be2e14058664b987ed84c870f3a...
  twitter_api_key: XXXXX
  twitter_api_secret: YYYYY
```
<hr>
Begin by adding the gem `omniauth-twitter` to `Gemfile`
```ruby
# Gemfile

gem 'omniauth-twitter'

# Don't forget to bundle after
```



## Debugging Tips


## NoSQL
