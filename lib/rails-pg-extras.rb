# frozen_string_literal: true

require 'terminal-table'
require 'ruby-pg-extras'

module RailsPGExtras
  QUERIES = RubyPGExtras::QUERIES
  DEFAULT_ARGS = RubyPGExtras::DEFAULT_ARGS
  NEW_PG_STAT_STATEMENTS = RubyPGExtras::NEW_PG_STAT_STATEMENTS

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
    if %i(calls outliers).include?(query_name)
      pg_stat_statements_ver = RailsPGExtras.connection.execute("select installed_version from pg_available_extensions where name='pg_stat_statements'")
        .to_a[0].fetch("installed_version", nil)
      if pg_stat_statements_ver != nil
        if Gem::Version.new(pg_stat_statements_ver) < Gem::Version.new(NEW_PG_STAT_STATEMENTS)
          query_name = "#{query_name}_legacy".to_sym
        end
      end
    end

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
end

require 'rails-pg-extras/railtie' if defined?(Rails)
