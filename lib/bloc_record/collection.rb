module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def take(num=1)
      taken_records = Collection.new
      if num > 1
        for i in (0..num) do
          taken_records << self[i]
        end
      else
        # return a single record, not a collection of 1
        return self.first
      end
      taken_records
    end

    def destroy_all
      ids = ""
      self.each do |object|
        ids << object.id + ", "
      end

      connection.execute <<-SQL
        DELETE FROM #{table}
        WHERE id in (#{ids})
      SQL
    end

    # assume args will always be a hash
    def where(args)
      where_records = Collection.new
      self.each do |record|
        total_match = true
        args.each_key do |key|
          total_match = false unless record[key] == args[key]
        end
        where_records << record if total_match == true
      end
      where_records
    end
  end
end
