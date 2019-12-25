# frozen_string_literal: true

require 'terminal-table'

module RailsPGExtras

  %i(
    bloat blocking cache_hit
     calls extensions
     index_size index_usage locks
     long_running_queries mandelbrot outliers
     records_rank seq_scans table_indexes_size
     table_size total_index_size total_table_size
     unused_indexes vacuum_stats
  ).each do |query_name|
    require "rails-pg-extras/queries/#{query_name}"

    define_singleton_method query_name do |options = { in_format: :display_table }|
      run_query(
        query_name: query_name,
        in_format: options.fetch(:in_format)
      )
    end
  end

  def self.run_query(query_name:, in_format:)
    result = connection.execute(self.public_send("#{query_name}_sql"))
    title = self.public_send("#{query_name}_description")
    display_result(result, title: title, in_format: in_format)
  end

  def self.display_result(result, title:, in_format:)
    case in_format
    when :array
      result.values
    when :hash
      result.to_a
    when :raw
      result
    when :display_table
      headings = if result.count > 0
        result[0].keys
      else
        ["No results"]
      end

      puts Terminal::Table.new(
        title: title,
        headings: headings,
        rows: result.values
      )
    else
      raise "Invalid in_format option"
    end
  end

  def self.connection
    ActiveRecord::Base.connection
  end

  private_class_method :connection
  private_class_method :display_result
end
