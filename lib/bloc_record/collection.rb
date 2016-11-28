module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
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

    def group(*args)
      ids = self.map(&:id)
      self.any? ? self.first.class.group_by_ids(ids, args) : false
    end

    def distinct
      new_collection = Collection.new
      length_minus_one = new_collection.length - 1

      self.each do |original_entry|
        entry_distinct = true
        new_collection.each do |collection_entry|
          if original_entry == collection_entry
            entry_distinct = false
            break
          end
        end
        new_collection << original_entry if entry_distinct == true
      end

      new_collection
    end

    def take(num=1)
      taken_records = Collection.new
      if num > 1
        for i in (0..num) do
          taken_records << self[i]
        end
      else
        return self.first
      end
      taken_records
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
