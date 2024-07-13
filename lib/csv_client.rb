require 'csv'

class CsvClient
  # Example usage
  def initialize
    @file_path = '../data/customer.csv'
  end

  # Create (Insert) a new record
  def create_record(record)
    CSV.open(@file_path, 'a+') do |csv|
      csv << record
    end
  end

  # Read all records
  def read_records
    CSV.foreach(@file_path, headers: true) do |row|
      puts row.to_h
    end
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
    table.each do |row|
      next unless row[:email] == target_email

      row[:name] = updated_record[0]
      row[:email] = updated_record[1]
      row[:phone] = updated_record[2]
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
    existing_record = find_record(@file_path, target_email)
    if existing_record
      existing_record
    else
      create_record(new_record)
      new_record
    end
  end
end
