# frozen_string_literal: true

module RailsPgExtras
  class TableInfo < RubyPgExtras::TableInfo
    private

    def query_module
      RailsPgExtras
    end
  end
end
