require_relative '../lib/csv_client'
require_relative '../lib/door_keeper'

csv_client = CsvClient.new

csv_client.read_records.each do |record|
  next if record['granted_until'].nil?

  door_keeper = DoorKeeper.new(record)
  door_keeper.revoke(record)
end
