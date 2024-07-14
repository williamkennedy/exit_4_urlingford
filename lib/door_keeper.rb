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
    add_customer_to_csv(event)
    case event.data.object.metadata.module
    when 'meetingrooms'
      add_meeting_room_access
    when 'desks'
      add_desk_access
    end
  end

  def grant(record)
    email = record[:email]
    granted_until = record[:granted_until]
    return if granted_until.nil?

    puts "granting access for #{email}" if equal_or_greater_than_today?(granted_until)
    # TODO: grant access to unfi
  end

  # revoke access
  def revoke(record)
    return if record[:granted_until].nil?

    puts 'check if should revoke'
    return if equal_or_greater_than_today?(record[:granted_until])

    puts "revoking access for #{record[:email]}"
    # TODO: revoke access to unfi
  end

  private

  def add_meeting_room_access
    puts 'granting meetingroom access'
  end

  def add_desk_access
    last_date = extract_date(@event.data.object.metadata.description)
    parsed_date = Date.strptime(last_date, '%d/%m/%Y')
    if equal_or_greater_than_today?(last_date)
      puts 'granting access'
      puts "The date #{parsed_date} is greater than or equal to today's date #{Date.today}."
    else
      puts 'access denied'
      puts "The date #{parsed_date} is less than today's date #{Date.today}."
    end
  end

  def equal_or_greater_than_today?(date_string)
    parsed_date = Date.strptime(date_string, '%d/%m/%Y')
    today_date = Date.today
    parsed_date >= today_date
  end

  # stripe id, event metadata**, booking type, grant status
  def add_customer_to_csv(event)
    puts event.data.object.metadata
    row = [@customer.email, @customer.id,
           extract_date(event.data.object.metadata.description)].concat(event.data.object.metadata.values)
    @csv_client.find_or_create_record(@customer.email, row)
    @csv_client.update_record(@customer.email, row)
  end

  def extract_date(text)
    pattern = %r{\b\d{2}/\d{2}/\d{4}\b}

    # Find the first occurrence of the pattern in the string
    match = text.match(pattern)

    return unless match

    match.to_a.last
  end
end

# todo
# USE CSV to manage DoorKeeper
# implemet revoke
