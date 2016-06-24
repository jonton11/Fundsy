## Stripe Lecture (Thursday, June 2nd Lecture)

<hr>

Using Stripe we can integrate the ability to make payments with credit cards to our application. We utilize the Stripe Ruby API and the Stripe JS API to handle the transactions between our Rails App, Client, and Stripe.

To access your API key:
- Sign Up
- Click on Your Name or Your Account in the top right
- Click the API keys tab
- Copy the test keys and add them to `secrets.yml`

Google the JavaScript Stripe API and navigate to Custom Payment Form

Add the following to your `application.html.erb`

```erb
<!-- application.html.erb -->

<script type="text/javascript" src="https://js.stripe.com/v2/"></script>
```


`bin/rails g migration add_stripe_fields_to_users stripe_customer_id stripe_card_type stripe_card_last4 stripe_card_exp_month:integer stripe_card_exp_year:integer`
