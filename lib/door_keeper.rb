require_relative 'csv_client'
require_relative 'unifi_access_api'

class DoorKeeper
  attr_accessor :event, :customer

  def initialize(customer)
    @customer = customer
    @csv_client = CsvClient.new
    @unfi_access_api = UnifiAccessApi.new
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
    email = record['email']
    granted_until = record['granted_until']
    invite_sent = record['invite_sent']
    return if granted_until.nil?

    puts "granting access for #{email}" if equal_or_greater_than_today?(granted_until)
    return unless equal_or_greater_than_today? granted_until

    i = 1
    response = @unfi_access_api.get_users(i)
    users = response['data']

    while users.count < response.dig('pagination', 'total').to_i
      i += 1
      response = @unfi_access_api.get_users(i)
      break if response['code'] != 'SUCCESS'

      users.concat(response.dig('data'))
    end

    user = users.select { |user| user['email'] == email || user['user_email'] == email }
    user = user.first if user.is_a? Array
    puts user.inspect
    user = create_user(email) if user.nil?
    return if user.nil?

    # grant_access to policy
    @unfi_access_api.add_access(user)

    
    # invite_user if unverifed
    invite_user_if_univited(user)
  end

  # revoke access
  def revoke(record)
    email = record['email']
    granted_until = record['granted_until']

    return if equal_or_greater_than_today?(granted_until)

    puts "revoking access for #{email}"
    i = 1
    response = @unfi_access_api.get_users(i)
    users = response['data']

    while users.count < response.dig('pagination', 'total').to_i
      i += 1
      response = @unfi_access_api.get_users(i)
      break if response['code'] != 'SUCCESS'

      users.concat(response.dig('data'))
    end
    users.flatten

    user = users.select { |user| user['email'] == email || user['user_email'] == email }
    user = user.first if user.is_a? Array
    return if user.nil?
     
    @unfi_access_api.remove_access(user)
  end

  private

  def create_user(email)
    response = @unfi_access_api.create_user(email)
    response.dig('data')
  end

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
    row = [@customer.email, @customer.id,
           extract_date(event.data.object.metadata.description), 'no'].concat(event.data.object.metadata.values)
    @csv_client.find_or_create_record(@customer.email, row)
    @csv_client.update_record(@customer.email, row)
  end

  def invite_user_if_univited(user)

    client = CsvClient.new('invites.csv')
    return if client.find_record(user['user_email'])
    return unless user['email_status'] == 'UNVERIFED'


    @unfi_access_api.invite(user)
    client.find_or_create_record(user['user_email'], [user['user_email']])
  end


  def extract_date(text)
    pattern = %r{\b\d{2}/\d{2}/\d{4}\b}

    # Find the first occurrence of the pattern in the string
    match = text.match(pattern)

    return unless match

    match.to_a.last
  end
end
