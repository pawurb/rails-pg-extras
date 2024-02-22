# frozen_string_literal: true

module RailsPgExtras
  class DiagnoseData < ::RubyPgExtras::DiagnoseData
    private

    def query_module
      RailsPgExtras
    end
  end
end
