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
        args: options.fetch(:args, {})
      )
    end
  end

  def self.run_query(query_name:, in_format:, args: {})
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

    result = connection.execute(sql)

    RubyPgExtras.display_result(
      result,
      title: RubyPgExtras.description_for(query_name: query_name),
      in_format: in_format
    )
  end

  def self.diagnose(in_format: :display_table)
    data = RailsPgExtras::DiagnoseData.call

    if in_format == :display_table
      RailsPgExtras::DiagnosePrint.call(data)
    elsif in_format == :hash
      data
    else
      raise "Invalid 'in_format' argument!"
    end
  end

  def self.measure_duration(&block)
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    block.call
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = ending - starting
    elapsed
  end

  def self.measure_queries(&block)
    queries = {}
    sql_duration = 0

    method_name = if ActiveSupport::Notifications.respond_to?(:monotonic_subscribe)
      :monotonic_subscribe
    else
      :subscribe
    end

    subscriber = ActiveSupport::Notifications.public_send(method_name, "sql.active_record") do |_name, start, finish, _id, payload|
      unless payload[:name] =~ /SCHEMA/
        key = payload[:sql]
        queries[key] ||= { count: 0, total_duration: 0, min_duration: nil, max_duration: nil }
        queries[key][:count] += 1
        duration = finish - start
        queries[key][:total_duration] += duration
        sql_duration += duration

        if queries[key][:min_duration] == nil || queries[key][:min_duration] > duration
          queries[key][:min_duration] = duration
        end

        if queries[key][:max_duration] == nil || queries[key][:max_duration] < duration
          queries[key][:max_duration] = duration
        end
      end
    end

    total_duration = measure_duration do
      block.call
    end

    queries = queries.reduce({}) do |agg, val|
      val[1][:avg_duration] = val[1][:total_duration] / val[1][:count]
      agg.merge(val[0] => val[1])
    end

    ActiveSupport::Notifications.unsubscribe(subscriber)
    {
      count: queries.reduce(0) { |agg, val| agg + val[1].fetch(:count) },
      queries: queries,
      total_duration: total_duration,
      sql_duration: sql_duration
    }
  end

  def self.index_info(args: {}, in_format: :display_table)
    data = RailsPgExtras::IndexInfo.call(args[:table_name])

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

  def self.table_info(args: {}, in_format: :display_table)
    data = RailsPgExtras::TableInfo.call(args[:table_name])

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

  def self.connection
    if (db_url = ENV['RAILS_PG_EXTRAS_DATABASE_URL'])
      ActiveRecord::Base.establish_connection(db_url).connection
    else
      ActiveRecord::Base.connection
    end
  end
end

require 'rails_pg_extras/web'
require 'rails_pg_extras/configuration'
require 'rails_pg_extras/railtie' if defined?(Rails)
