# frozen_string_literal: true

module RailsPGExtras
  class DiagnoseData < RubyPGExtras::DiagnoseData

    private

    def query_module
      RailsPGExtras
    end
  end
end
