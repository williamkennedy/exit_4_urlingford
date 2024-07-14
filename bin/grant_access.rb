require 'date'
require_relative '../lib/door_keeper'
require_relative '../lib/stripe_client'

class Date
  def self.yesterday
    Date.today - 7
  end
end

stripe = StripeClient.new
csv_client = CsvClient.new

# get todays events based on payment_intent.succeeded
# get customers name based on thier customer id and their email
# based on plan name grant access on CSV

# Get today's date in UTC and format it
today_start = Date.today.to_time.to_i
today_end = (Date.today + 1).to_time.to_i

yesterday_start = Date.yesterday.to_time.to_i
yesterday_end = Date.today.to_time.to_i

events = stripe.events({ type: 'payment_intent.succeeded',
                         created: {
                           gte: yesterday_start,
                           lt: today_end
                         } })

# Print the events
events.to_a.reverse.each do |event|
  customer = stripe.customer(event.data.object.customer)
  door_keeper = DoorKeeper.new(customer)
  door_keeper.triage_knock_event(event)
  door_keeper.grant(csv_client.find_record(customer.email)) unless csv_client.find_record(customer.email).nil?
end
