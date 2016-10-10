module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def group(*args)
      ids = self.map(&:id)
      self.any? ? self.first.class.group_by_ids(ids, args) : false
    end

    def distinct
      # new collection object to return
      distinct_record = Collection.new
      # loop through collection and check for duplications
      # this is O(n^2), right? so extremely inefficient
      for i in (0..self.length - 1) do
        # compares each entry in self to each other entry in self
        self.each do |entry|
          # if there is a match, break out of the current loop iteration
          # because the entry is not "distinct"
          if self[i] == entry
            break
          else
            # if there is no match, the record is distinct
            # because the assignment asks for a single record, we return this first match
            return distinct_record << self[i]
          end
        end
      end
      # return first distinct in this new Array
      distinct_array.first
    end

    def take(num=1)
      rows = connection.execute <<-SQL
        SELECT * FROM #{table}
        LIMIT #{num}
      SQL
    end

    def where(*args) # is there any reason that I can't use the same method from selection here?
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
  end
end
