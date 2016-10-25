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
      puts "------------"
      puts "Collection at 0: #{new_collection[0]}"
      puts "------------"
      puts "Collection at 2: #{new_collection[2]}"
      puts "------------"
      puts "Collection at 3: #{new_collection[3]}"
      puts "------------"
      puts "new_collection[0] == new_collection[2]: #{new_collection[0] == new_collection[2]}"
      puts "new_collection[0] == new_collection[3]: #{new_collection[0] == new_collection[3]}"
      puts "------------"
      # pointer = 0
      # length_minus_one = new_collection.length - 1
      # new_collection[0..(length_minus_one)].each do |record|
      #   for i in (pointer + 1)..length_minus_one do
      #      new_collection.delete_at(i) if new_collection[pointer] == new_collection[i]
      #   end
      # end
      # new_collection
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
