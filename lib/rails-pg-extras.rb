# frozen_string_literal: true

require 'terminal-table'
require 'ruby-pg-extras'

module RailsPGExtras
  QUERIES = RubyPGExtras::QUERIES
  DEFAULT_ARGS = RubyPGExtras::DEFAULT_ARGS

  QUERIES.each do |query_name|
    define_singleton_method query_name do |options = {}|
      run_query(
        query_name: query_name,
        in_format: options.fetch(:in_format, :display_table),
        args: options.fetch(:args, {})
      )
    end
  end

  def self.run_query(query_name:, in_format:, args: {})
    sql = if (custom_args = DEFAULT_ARGS[query_name].merge(args)) != {}
      RubyPGExtras.sql_for(query_name: query_name) % custom_args
    else
      RubyPGExtras.sql_for(query_name: query_name)
    end

    result = connection.execute(sql)

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
