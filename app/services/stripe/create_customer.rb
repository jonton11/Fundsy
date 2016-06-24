class Stripe::CreateCustomer # :nodoc:
  include Virtus.model

  attribute :stripe_token, Stripe
  attribute :user, User

  def call
    # .create here will make an HTTP request
    create_stripe_customer && save_data_from_stripe
  end

  private

  def save_data_from_stripe
    user.stripe_customer_id     = @customer.id
    user.stripe_card_type       = @customer.sources.data[0].brand
    user.stripe_card_last4      = @customer.sources.data[0].last4
    user.stripe_card_exp_month = @customer.sources.data[0].exp_month
    user.stripe_card_exp_year  = @customer.sources.data[0].exp_year
    user.save
  end

  def create_stripe_customer
    # Whenever we access an external object, wrap in begin/rescue
    begin
      @customer = Stripe::Customer.create(stripe_customer_details)
    rescue => e
      # Notify admin with error e.message / e.backtrace
      false
    end
  end

  def description
    "Customer for user id #{user.id}"
  end

  def stripe_customer_details
    { description: description, source: stripe_token }
  end

end
