require 'date'
require_relative '../lib/door_keeper'
require_relative '../lib/stripe_client'

class Date
  def self.yesterday
    Date.today - 1
  end
end

stripe = StripeClient.new

# get todays events based on payment_intent.succeeded
# get customers name based on thier customer id and their email
# based on plan name grant access on CSV

# Get today's date in UTC and format it
today_start = Date.today.to_time.to_i
today_end = (Date.today + 1).to_time.to_i

yesterday_start = Date.yesterday.to_time.to_i
yesterday_end = Date.today.to_time.to_i

events = stripe.events({ type: 'payment_intent.created',
                         created: {
                           gte: today_start,
                           lt: today_end
                         } })

# Print the events
events.each do |event|
  customer = stripe.customer(event.data.object.customer)
  door_keeper = DoorKeeper.new(customer)
  door_keeper.triage_knock_event(event)

  # this returns dates at the end
  # So create or find a csv with that date as the name and add user to it
  # Cronjob will then look at that csv file and grant access if not already granted
end
