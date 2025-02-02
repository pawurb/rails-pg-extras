# frozen_string_literal: true

module RailsPgExtras
  class MissingFkConstraints < RubyPgExtras::MissingFkConstraints
    private

    def query_module
      RailsPgExtras
    end
  end
end
