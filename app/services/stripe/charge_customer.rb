class Stripe::ChargeCustomer

  include Virtus.model

  attributes :user, User
  attributes :amount, Integer
  attributes :description, String

  attribute :charge_id, String

  def call
    begin
      charge = Stripe::Charge.create charge_details
      @charge_id = charge.id
    rescue => e
      false
    end
  end

  private

  def charge_details
    {
      # This is an integer of cents
      amount: amount,
      currency: 'cad',
      customer: 'cus_8ZDH6y4RQ9VLOB',
      description: description
    }
  end
end
