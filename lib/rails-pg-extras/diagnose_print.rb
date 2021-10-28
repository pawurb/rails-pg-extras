# frozen_string_literal: true

require 'colorize'
require 'terminal-table'

module RailsPGExtras
  class DiagnosePrint < RubyPGExtras::DiagnosePrint

    private

    def title
      "rails-pg-extras - diagnose report"
    end
  end
end
