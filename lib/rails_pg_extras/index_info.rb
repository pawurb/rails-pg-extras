# frozen_string_literal: true

module RailsPgExtras
  class IndexInfo < RubyPgExtras::IndexInfo
  
    def self.call(table_name = nil, db_name: nil)
      return super(table_name) if db_name.nil?

      # To not change RubyPgExtras's code it exploit RailsPgExtras would
      # execute the query on the first Database when there is only 1 connection
      temp_connection = RailsPgExtras.connections
      RailsPgExtras.connections = [RailsPgExtras.connection(db_name: db_name)]

      data = super(table_name)
      RailsPgExtras.connections = temp_connection

      data
    end
  
    private

    def query_module
      RailsPgExtras
    end
  end
end
