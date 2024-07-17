require 'csv'

class CsvClient
  # Example usage
  def initialize(name='customer.csv')
    @file_path = File.join('data', name)
    return if File.exist?(@file_path)

    CSV.open(@file_path, 'w') do |csv|
      csv << %w[email id granted_until invite_sent].concat(Array.new(20, ''))
    end
  end

  # Create (Insert) a new record
  def create_record(record)
    CSV.open(@file_path, 'a+') do |csv|
      csv << record
    end
  end

  # Read all records
  def read_records
    records = []
    CSV.foreach(@file_path, headers: true) do |row|
      records << row.to_h.transform_keys(&:to_sym)
    end
    records
  end

  # Find a specific record
  def find_record(target_email)
    CSV.foreach(@file_path, headers: true) do |row|
      return row.to_h if row['email'] == target_email
    end
    nil
  end

  # Update a specific record
  def update_record(target_email, updated_record)
    table = CSV.table(@file_path)
    headers = table.headers
    table.each do |row|
      next unless row[:email] == target_email

      updated_hash = Hash[headers.zip(updated_record)]
      headers.each do |header|
        row[header] = updated_hash[header] || nil
      end
    end
    File.open(@file_path, 'w') { |f| f.write(table.to_csv) }
  end

  # Delete a specific record
  def delete_record(target_email)
    table = CSV.table(@file_path)
    table.delete_if do |row|
      row[:email] == target_email
    end
    File.open(@file_path, 'w') { |f| f.write(table.to_csv) }
  end

  # Find or create a record
  def find_or_create_record(target_email, new_record)
    existing_record = find_record(target_email)
    if existing_record
      existing_record
    else
      create_record(new_record)
      new_record
    end
  end
end
