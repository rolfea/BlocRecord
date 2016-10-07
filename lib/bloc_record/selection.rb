require 'sqlite3'

module Selection
  def find(ids)
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

    init_object_from_row(row)
  end

  def find_by(attribute, value)
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join(",")} FROM #{table}
      WHERE attribute = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    init_object_from_row(row)
  end

  def take(num=1)
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join(",")} FROM #{table}
        ORDER BY random()
        LIMIT #{num}
      SQL

      rows_to_array(row)
    else
      take_one
    end
  end

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join(",")} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join(",")} FROM #{table}
      ORDER BY id
      ASC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join(",")} FROM #{table}
      ORDER BY id
      DESC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join(",")} FROM #{table};
    SQL

    rows_to_array(rows)
  end

  def select(*fields)
    rows = connection.execute <<-SQL
      SELECT #{fields * ", "} FROM #{table}
    SQL

    rows_array = rows_to_arrays(rows)
    rows_array.each do |row|
      if row.contains?("null")
        raise MissingAttributeError, "MissingAttributeError: missing attribute: #{row}"
      else
        rows_array
      end
    end
  end

  def limit(value, offset=0)
    rows = connection.execute <<-SQL
      SELECT * FROM #{table}
      LIMIT #{value} OFFSET #{offset}
    SQL
    rows_to_array(rows)
  end

  def group(*args)
    conditions = args.join(', ')

    rows = connection.execute <<-SQL
      SELECT * FROM #{table}
      GROUP BY #{conditions}
    SQL

    rows_to_array(rows)
  end

  def where(*args)
    # check for nil
    if args.length == 0 # where returns object with a #not method
    def not(*args) # does where execute the conditional first if no params passed to it?
      if args.count > 1
        expression = args.shift
        expression.insert(0, "!") # flip the expression for negation
        params = args
      else
        case args.first
        when String
          expression = args.first
          expression.insert(0, "!") # flip the expression for negation
        when Hash
          expression_hash = BlocRecord::Utility.convert_keys(args.first)
          expression = expression_hash.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" AND ")
          expression.insert(0, "!") # flip the expression for negation
        end
      end

      sql = <<-SQL
        SELECT #{columns.join(",")} FROM #{table}
        WHERE #{expression};
      SQL

      rows = connection.execute(sql, params)
      return rows_to_array(rows)
    end

    if args.count > 1
      expression = args.shift
      params = args
    else
      case args.first
      when String
        expression = args.first
      when Hash
        expression_hash = BlocRecord::Utility.convert_keys(args.first)
        expression = expression_hash.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
      end
    end

    sql = <<-SQL
      SELECT #{columns.join(",")} FROM #{table}
      WHERE #{expression};
    SQL

    rows = connection.execute(sql, params)
    rows_to_array(rows)
  end

def order(*args)
    if args.count > 1
      order = args.join(",")
      order.each_with_index do |param, index|
        # multiple ordering conditions wrapped in (), separated by ,
        if order[index] == "ASC" || order[index] == "DESC"
          order[index] << "),"
          order[index - 1].insert(0, "(")
        end
      end
    else
      order = args.first.to_s
    end
    rows = connection.execute <<-SQL
      SELECT * FROM #{table}
      ORDER BY #{order};
    SQL
    rows_to_arrays(rows)
  end

  def join(*args)
    if args.count > 1
      joins = args.map { |arg| "INNER JOIN #{arg} ON #{arg}.#{table}_id = #{table}.id"}.join(" ")
      rows = connection.execute <<-SQL
        SELECT * FROM #{table} #{joins}
      SQL
    else
      case arg.first
      when String
        rows = connection.execute <<-SQL
          SELECT * FROM #{table} #{BlocRecord::Utility.sql_strings(arg)};
        SQL
      when Symbol
        rows = connection.execute <<-SQL
          SELECT * FROM #{table}
          INNER JOIN #{arg} ON #{arg}.#{table}_id = #{table}.id
        SQL
      when Hash
        expression_hash = BlocRecord::Utility.convert_keys(args.first)
        expression = expression_hash.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(",")
        rows = connection.execute <<-SQL
          SELECT * FROM #{table}
          INNER JOIN #{expression[0]} ON #{expression[0]}.#{table}_id = #{table}.id
          INNER JOIN #{expression[1]} ON #{expression[1]}.#{expression[0]}_id = #{table}.id
        SQL
      end
    end
    rows_to_array(rows)
  end

  private

  def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end

  def rows_to_array(rows)
    collection = BlocRecord::Collection.new
    rows.each { |row| collection << new(Hash[columns.zip(row)]) }
    collection
  end

  # custom error class inherits from StandardError
  class MissingAttributeError < StandardError
  end
end
