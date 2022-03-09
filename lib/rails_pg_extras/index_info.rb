# frozen_string_literal: true

module RailsPgExtras
  class IndexInfo < RubyPgExtras::IndexInfo
    private

    def query_module
      RailsPgExtras
    end
  end
end
