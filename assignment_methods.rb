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

def find_all_by(attribute, value)
  rows = connection.execute <<-SQL
    SELECT #{columns.join(",")} FROM #{table}
    WHERE attribute = #{BlocRecord::Utility.sql_strings(value)};
  SQL

  rows_to_array(rows)
end
