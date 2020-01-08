# frozen_string_literal: true

require 'terminal-table'
require 'ruby-pg-extras'

module RailsPGExtras
  QUERIES = RubyPGExtras::QUERIES

  QUERIES.each do |query_name|
    define_singleton_method query_name do |options = { in_format: :display_table }|
      run_query(
        query_name: query_name,
        in_format: options.fetch(:in_format)
      )
    end
  end

  def self.run_query(query_name:, in_format:)
    result = connection.execute(
      RubyPGExtras.sql_for(query_name: query_name)
    )

    RubyPGExtras.display_result(
      result,
      title: RubyPGExtras.description_for(query_name: query_name),
      in_format: in_format
    )
  end

  def self.connection
    ActiveRecord::Base.connection
  end

  private_class_method :connection
end

require 'rails-pg-extras/railtie' if defined?(Rails)
