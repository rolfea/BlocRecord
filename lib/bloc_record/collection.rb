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
        taken_records << self.first
      end
      taken_records
    end

    def where(*args)
      where_records = Collection.new
      # assuming the collection Object responds to Object.id syntax
      # assuming args is a Hash - for string would need regex?
      self.each do |record|
        if record.args.first.key == args.first[args.first.key]
          where_records << record
        end
      end
      where_records
    end
  end
end
