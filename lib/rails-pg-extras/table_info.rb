# frozen_string_literal: true

module RailsPGExtras
  class TableInfo < RubyPGExtras::TableInfo
    private

    def query_module
      RailsPGExtras
    end
  end
end
