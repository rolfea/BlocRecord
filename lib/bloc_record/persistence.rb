require 'sqlite3'
require 'bloc_record/schema'

module Persistence
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def create(attrs)
      attrs = BlocRecord::Utility.convert_keys(attrs)
      attrs.delete("id")
      vals = attributes.map {|key| BlocRecord::Utility.sql_strings(attrs[key])}

      connection.execute <<-SQL
        INSERT INTO #{table} (#{attributes.join(",")})
        VALUES (#{vals.join(",")});
      SQL

      data = Hash[attributes.zip attrs.values]
      data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
      new(data)
    end

    def update(ids, updates)
      # add a check for class of updates in case an array of attributes for diff
      # records is passed (assignment 5)
      if updates.class == Hash
        updates = BlocRecord::Utility.convert_keys(updates)
        updates.delete("id")
        updates_array = updates.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }
      elsif updates.class == Array
        updates_array = updates
      end

      if ids.class == Fixnum
        where_clause = "WHERE id = #{ids};"
      elsif ids.class == Array
        where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
      else
        where_clause = ";"
      end

      connection.execute <<-SQL
        UPDATE #{table}
        SET #{updates_array * ","} #{where_clause}
      SQL

      true
    end

    def destroy(*id)
      if id.length > 1
        where_clause = "WHERE id IN (#{id.join(",")})"
      else
        where_clause = "WHERE id = #{id.first};"
      end

      connection.execute <<-SQL
        DELETE FROM #{table}
        #{where_clause}
      SQL

      true
    end

    def destroy_all(conditions=nil)
      # #3 from assignment, using execute(sql, params) syntax
      if conditions.length > 1
        sql_expression = conditions.shift
        params = conditions

        sql = <<-SQL
          DELETE FROM #{table}
          WHERE #{sql_expression}
        SQL

        connection.execute(sql, params)
      # Hash passed in a condition
      elsif conditions.first.class == Hash && !conditions.empty?
        conditions = BlocRecord::Utility.convert_keys(conditions)
        conditions = conditions.map {|key, value| "#{key} = #{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")

        connection.execute <<-SQL
          DELETE FROM #{table}
          WHERE #{conditions}
        SQL
      # #2 from assignment. String passed as condition
      elsif conditions.first.class == String && !conditions.empty?
        connection.execute <<-SQL
          DELETE FROM #{table}
          WHERE #{conditions}
        SQL
      else
        connection.execute <<-SQL
          DELETE FROM #{table}
        SQL
      end


      true
    end

    def save!
      unless self.id
        self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
        BlocRecord::Utility.reload_obj(self)
        return true
      end

      fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")

      self.class.connection.execute <<-SQL
        UPDATE  #{self.class.table}
        SET #{fields}
        WHERE id = #{self.id}
      SQL

      true
    end

    def save
      self.save! rescue false
    end

    def update_attribute(attribute, value)
      self.class.update(self.id, { attribute => value })
    end

    def update_attributes(updates)
      self.class.update(self.id, updates)
    end

    def destroy
      self.class.destroy(self.id)
    end

    def update_all(updates)
      update(nil, updates)
    end

    def self.method_missing(method_symbol, *arguments, &block)
      if method_symbol.to_s =~ /^update_(.*)$/
        update_attribute($1.to_sym => arguments.first) # does this auto fill in the provided arguments?
      else
        super #looks for the method in parent classes
      end
    end
  end
end
