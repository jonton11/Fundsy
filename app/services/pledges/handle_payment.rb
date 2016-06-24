class Pledges::HandlePayment # :nodoc:

  include Virtus.model

  attribute :stripe_token, String
  attribute :user,         User
  attribute :pledge,       Pledge

  def call
    create_stripe_customer && charge_stripe_customer && set_pledge_txn_id
  end

  private

  def create_stripe_customer
    Stripe::CreateCustomer.new(stripe_token: stripe_token, user: user).call
  end

  def charge_stripe_customer
    service = Stripe::ChargeCustomer.new(user:        user,
                                         amount:      amount_in_cents,
                                         description: charge_description)
    @charge_id = service.charge_id if service.call
  end

  def set_pledge_txn_id
    pledge.txn_id = @charge_id
    pledge.save
  end

  def amount_in_cents
    (pledge.amount * 100).to_i
  end

  def charge_description
    "Charge for pledge id #{pledge.id}"
  end

end
