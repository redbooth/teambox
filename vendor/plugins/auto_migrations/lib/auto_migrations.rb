module AutoMigrations
  
  def self.run
    # Turn off schema_info code for auto-migration
    class << ActiveRecord::Schema
      alias :old_define :define
      def define(info={}, &block) instance_eval(&block) end
    end
  
    load(File.join(RAILS_ROOT, 'db', 'schema.rb'))
    ActiveRecord::Migration.drop_unused_tables
    ActiveRecord::Migration.drop_unused_indexes
  
    class << ActiveRecord::Schema
      alias :define :old_define
    end
  end
  
  def self.schema_to_migration
    schema = File.read(File.join(RAILS_ROOT, "db", "schema.rb"))
    schema.gsub!(/#(.)+\n/, '')
    schema.sub!(/ActiveRecord::Schema.define(.+)do[ ]?\n/, '')
    schema.gsub!(/^/, '  ')
    schema = "class InitialSchema < ActiveRecord::Migration\n  def self.up\n" + schema
    schema << "\n  def self.down\n"
    schema << (ActiveRecord::Base.connection.tables - ["schema_info"]).map do |table| 
                "    drop_table :#{table}\n"
              end.join
    schema << "  end\nend\n"
    migration_file = File.join(RAILS_ROOT, "db", "migrate", "001_initial_schema.rb")
    File.open(migration_file, "w") { |f| f << schema }
    puts "Migration created at db/migrate/001_initial_schema.rb"
  end
  
  def self.included(base)
    base.extend ClassMethods
    class << base
      cattr_accessor :tables_in_schema, :indexes_in_schema
      self.tables_in_schema, self.indexes_in_schema = [], []
      alias_method_chain :method_missing, :auto_migration
    end
  end

  module ClassMethods
  
    def method_missing_with_auto_migration(method, *args, &block)
      case method
      when :create_table
        auto_create_table(method, *args, &block)
      when :add_index
        auto_add_index(method, *args, &block)
      else
        method_missing_without_auto_migration(method, *args, &block) 
      end
    end
    
    def auto_create_table(method, *args, &block)
      table_name = args.shift.to_s    
      options    = args.pop || {}
        
      (self.tables_in_schema ||= []) << table_name

      # Table doesn't exist, create it
      unless ActiveRecord::Base.connection.tables.include?(table_name)
        return method_missing_without_auto_migration(method, *[table_name, options], &block)
      end
    
      # Grab database columns
      fields_in_db = ActiveRecord::Base.connection.columns(table_name).inject({}) do |hash, column|
        hash[column.name] = column
        hash
      end
    
      # Grab schema columns (lifted from active_record/connection_adapters/abstract/schema_statements.rb)
      table_definition = ActiveRecord::ConnectionAdapters::TableDefinition.new(ActiveRecord::Base.connection)
      table_definition.primary_key(options[:primary_key] || "id") unless options[:id] == false
      yield table_definition
      fields_in_schema = table_definition.columns.inject({}) do |hash, column|
        hash[column.name.to_s] = column
        hash
      end
    
      # Add fields to db new to schema
      (fields_in_schema.keys - fields_in_db.keys).each do |field|
        column = fields_in_schema[field]
        add_column table_name, column.name, column.type.to_sym, :limit => column.limit, :precision => column.precision, 
          :scale => column.scale, :default => column.default, :null => column.null
      end
    
      # Remove fields from db no longer in schema
      (fields_in_db.keys - fields_in_schema.keys & fields_in_db.keys).each do |field|
        column = fields_in_db[field]
        remove_column table_name, column.name
      end
      
      # Change field type if schema is different from db
      (fields_in_schema.keys & fields_in_db.keys).each do |field|
        if (field != 'id') && (fields_in_schema[field].type.to_sym != fields_in_db[field].type.to_sym)
          change_column table_name, fields_in_schema[field].name.to_sym, fields_in_schema[field].type.to_sym
        end
      end
    end
    
    def auto_add_index(method, *args, &block)      
      table_name = args.shift.to_s
      fields     = Array(args.shift).map(&:to_s)
      options    = args.shift

      index_name = options[:name] if options  
      index_name ||= "index_#{table_name}_on_#{fields.join('_and_')}"

      (self.indexes_in_schema ||= []) << index_name
      
      unless ActiveRecord::Base.connection.indexes(table_name).detect { |i| i.name == index_name }
        method_missing_without_auto_migration(method, *[table_name, fields, options], &block)
      end
    end
  
    def drop_unused_tables
      (ActiveRecord::Base.connection.tables - tables_in_schema - ["schema_info"]).each do |table|
        drop_table table
      end
    end
    
    def drop_unused_indexes
      tables_in_schema.each do |table_name|
        indexes_in_db = ActiveRecord::Base.connection.indexes(table_name).map(&:name)
        (indexes_in_db - indexes_in_schema & indexes_in_db).each do |index_name|
          remove_index table_name, :name => index_name
        end
      end
    end
  
  end

end
