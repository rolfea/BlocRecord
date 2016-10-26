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
      new_collection = self
      length_minus_one = new_collection.length - 1

      for p in 0..length_minus_one do
        pointer = p
        for i in (pointer + 1)..length_minus_one do
          new_collection.delete_at(i) if new_collection[pointer] == new_collection[i]
        end
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
