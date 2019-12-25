# frozen_string_literal: true

require 'terminal-table'
require 'rails-pg-extras/locks'
require 'rails-pg-extras/index_size'

module RailsPGExtras
  def self.connection
    ActiveRecord::Base.connection
  end

  def self.display_result(result, in_format:)
    case in_format
    when :array
      result.values
    when :hash
      result.to_a
    when :raw
      result
    when :display_table
      puts Terminal::Table.new(rows: result.values)
    else
      raise "Invalid in_format option"
    end
  end

  private_class_method :connection
  private_class_method :display_result
end
