def snake_to_camel(snake_string)
  string = snake_string.gsub(/(_[a-z])/) {|match| match[1].upcase}
end

def find_by(contact, contact_id)
  results = connection.execute <<-SQL
    SELECT #{contact} FROM #{table}
    WHERE contact_id = #{contact_id}
  SQL
  results
end

def find_each(hash)
  rows = connection.execute <<-SQL
    SELECT #{columns.join(",")} FROM #{table}
    WHERE id = #{hash[:start]} LIMIT #{hash[:batch_size]}
  SQL
  # passes each entry in array to block iterator
  current_row_index = 0
  while current_row_index <= rows.length - 1
    yield rows[current_row_index]
    current_row_index += 1
  end
end

def find_in_batches(hash)
  # load the array of rows
  rows = connection.execute <<-SQL
    SELECT #{columns.join(",")} FROM #{table}
    WHERE id = #{hash[:start]} LIMIT #{hash[:batch_size]}
  SQL
  # pass the full rows array to block iterator
  yield rows
end
