# frozen_string_literal: true

module RailsPgExtras
  class MissingFkIndexes < RubyPgExtras::MissingFkIndexes
    private

    def query_module
      RailsPgExtras
    end
  end
end
