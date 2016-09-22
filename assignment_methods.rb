def snake_to_camel(snake_string)
  string = snake_string.gsub(/(_[a-z])/) {|match| match[1].upcase}
end

def find_by(attribute, value)
  results = connection.execute <<-SQL
    SELECT #{attribute} FROM #{table}
    WHERE value = #{value}
  SQL
  results
end
