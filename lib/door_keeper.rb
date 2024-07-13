require_relative 'csv_client'

class DoorKeeper
  attr_accessor :event, :customer

  def initialize(customer)
    @customer = customer
    @csv_client = CsvClient.new
  end

  def triage_knock_event(event)
    @event = event
    puts "Event ID: #{event.id}, Type: #{@event.type}, Customer Email: #{@customer.email} Created: #{Time.at(event.created)}"
    puts "Customer #{@customer.email} bought on #{event.data.object.metadata.description}"
    add_customer_to_csv
    case event.data.object.metadata.module
    when 'meetingrooms'
      grant_meeting_room_access
    when 'desks'
      grant_desk_access
    end
  end

  # revoke access
  def revoke; end

  private

  def grant_meeting_room_access
    puts 'granting meetingroom access'
  end

  def grant_desk_access
    puts 'granting desk access'
  end

  # stripe id, event metadata**, booking type, grant status
  def add_customer_to_csv
    puts 'adding to csv'
    @csv_client.find_or_create_record(@customer.email, [@customer.email])
  end

  # create or find user
  # grant access
  def grant; end
end
