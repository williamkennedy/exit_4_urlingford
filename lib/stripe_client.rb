require 'stripe'
require 'dotenv/load'

Stripe.api_key = ENV['STRIPE_SECRET_KEY']

class StripeClient
  def customer(id)
    Stripe::Customer.retrieve(id)
  end

  def customers(options = {})
    Stripe::Customer.list(options)
  end

  def charges_by_customer_id(options = {})
    Stripe::Charge.list(options)
  end

  def events(options = {})
    Stripe::Event.list(options)
  end
end
