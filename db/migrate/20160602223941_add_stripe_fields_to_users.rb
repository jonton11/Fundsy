class AddStripeFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_customer_id, :string
    add_column :users, :stripe_card_type, :string
    add_column :users, :stripe_card_last4, :string
    add_column :users, :stripe_card_exp_month, :integer
    add_column :users, :stripe_card_exp_year, :integer
  end
end
