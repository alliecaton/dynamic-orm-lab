require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  

    def self.table_name 
        self.to_s.downcase.pluralize
    end 

    def self.column_names
        DB[:conn].results_as_hash = true

        sql = "pragma table_info('#{table_name}')"
        table = DB[:conn].execute(sql)
        names = []
        table.each do |attributes| 
            names << attributes["name"]
        end
        names
    end

    def initialize(attributes={})
        attributes.each do |attribute, value|
            self.send(("#{attribute}="), value)
        end
    end


    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names[1..-1].join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end 

    def save 
        sql= <<-SQL
            INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
            VALUES (#{values_for_insert});
        SQL
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end  

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE name = ?
        SQL
        DB[:conn].execute(sql, name)
    end
    
    def self.find_by(attribute)
        col = attribute.keys.join()
        sql= <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE #{col} = ?
        SQL
        DB[:conn].execute(sql, attribute[col.to_sym])
    end
    
end