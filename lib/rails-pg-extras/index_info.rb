# frozen_string_literal: true

module RailsPGExtras
  class IndexInfo < RubyPGExtras::IndexInfo
    private

    def query_module
      RailsPGExtras
    end
  end
end
