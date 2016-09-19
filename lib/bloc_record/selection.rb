require 'sqlite3'

module Selection
  def find(#ids)
    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end
  
  def find_one(id)
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join(",")} FROM #{table}
      WHERE id = #{id};
    SQL
    data = Hash[columns.zip(row))]
    new(data)
  end
end
