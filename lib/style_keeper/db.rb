require 'active_record'
module StyleKeeper
  module DB
    def self.prepare
      database_path = 'cache.db'
      connect_database(database_path)
      create_tables_if_not_exists(database_path)
    end

    def self.connect_database(path)
      spec = { adapter: 'sqlite3', database: path }
      ActiveRecord::Base.establish_connection(spec)
    end

    def self.create_tables_if_not_exists(path)
      create_database_path(path)
      connection = ActiveRecord::Base.connection
      ContentsCache.create_table_if_not_exists(connection)
    end

    def self.create_database_path(path)
      FileUtils.mkdir_p(File.dirname(path))
    end

    private_class_method :connect_database, :create_tables_if_not_exists, :create_database_path
  end
end
