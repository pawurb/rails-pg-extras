# frozen_string_literal: true

require 'terminal-table'
require 'ruby-pg-extras'
require 'rails_pg_extras/diagnose_data'
require 'rails_pg_extras/diagnose_print'
require 'rails_pg_extras/index_info'
require 'rails_pg_extras/index_info_print'
require 'rails_pg_extras/table_info'
require 'rails_pg_extras/table_info_print'

module RailsPgExtras
  QUERIES = RubyPgExtras::QUERIES
  DEFAULT_ARGS = RubyPgExtras::DEFAULT_ARGS
  NEW_PG_STAT_STATEMENTS = RubyPgExtras::NEW_PG_STAT_STATEMENTS

  QUERIES.each do |query_name|
    define_singleton_method query_name do |options = {}|
      run_query(
        query_name: query_name,
        in_format: options.fetch(:in_format, :display_table),
        db_name: options[:db_name],
        args: options.fetch(:args, {})
      )
    end
  end

  def self.run_query(query_name:, in_format:, db_name: nil, args: {})
    if %i(calls outliers).include?(query_name)
      pg_stat_statements_ver = RailsPgExtras.connection.execute("select installed_version from pg_available_extensions where name='pg_stat_statements'")
        .to_a[0].fetch("installed_version", nil)
      if pg_stat_statements_ver != nil
        if Gem::Version.new(pg_stat_statements_ver) < Gem::Version.new(NEW_PG_STAT_STATEMENTS)
          query_name = "#{query_name}_legacy".to_sym
        end
      end
    end

    sql = if (custom_args = DEFAULT_ARGS[query_name].merge(args)) != {}
      RubyPgExtras.sql_for(query_name: query_name) % custom_args
    else
      RubyPgExtras.sql_for(query_name: query_name)
    end

    result = connection(db_name: db_name).execute(sql)

    RubyPgExtras.display_result(
      result,
      title: RubyPgExtras.description_for(query_name: query_name),
      in_format: in_format
    )
  end

  def self.diagnose(in_format: :display_table, db_name: nil)
    data = RailsPgExtras::DiagnoseData.call(db_name: db_name)

    if in_format == :display_table
      RailsPgExtras::DiagnosePrint.call(data)
    elsif in_format == :hash
      data
    else
      raise "Invalid 'in_format' argument!"
    end
  end

  def self.index_info(args: {}, in_format: :display_table, db_name: nil)
    data = RailsPgExtras::IndexInfo.call(args[:table_name], db_name: db_name)

    if in_format == :display_table
      RailsPgExtras::IndexInfoPrint.call(data)
    elsif in_format == :hash
      data
    elsif in_format == :array
      data.map(&:values)
    else
      raise "Invalid 'in_format' argument!"
    end
  end

  def self.table_info(args: {}, in_format: :display_table, db_name: nil)
    data = RailsPgExtras::TableInfo.call(args[:table_name], db_name: db_name)

    if in_format == :display_table
      RailsPgExtras::TableInfoPrint.call(data)
    elsif in_format == :hash
      data
    elsif in_format == :array
      data.map(&:values)
    else
      raise "Invalid 'in_format' argument!"
    end
  end

  def self.connection(db_name: nil)
    return ActiveRecord::Base.connection if @connections.blank?
    return @connections.first if db_name.nil?

    @connections.find { |connection| connection.current_database == db_name } || raise("Invalid database name argument!")
  end

  def self.connections
    @connections
  end

  def self.connections=(connections)
    @connections = connections
  end
end

require 'rails_pg_extras/web'
require 'rails_pg_extras/configuration'
require 'rails_pg_extras/railtie' if defined?(Rails)
