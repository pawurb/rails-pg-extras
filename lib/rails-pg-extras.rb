# frozen_string_literal: true

require "terminal-table"
require "ruby-pg-extras"
require "rails_pg_extras/diagnose_data"
require "rails_pg_extras/diagnose_print"
require "rails_pg_extras/index_info"
require "rails_pg_extras/index_info_print"
require "rails_pg_extras/missing_fk_indexes"
require "rails_pg_extras/missing_fk_constraints"
require "rails_pg_extras/table_info"
require "rails_pg_extras/table_info_print"

module RailsPgExtras
  extend self

  @@database_config = nil

  QUERIES = RubyPgExtras::QUERIES
  DEFAULT_ARGS = RubyPgExtras::DEFAULT_ARGS
  NEW_PG_STAT_STATEMENTS = RubyPgExtras::NEW_PG_STAT_STATEMENTS
  PG_STAT_STATEMENTS_17 = RubyPgExtras::PG_STAT_STATEMENTS_17

  QUERIES.each do |query_name|
    define_singleton_method query_name do |options = {}|
      run_query(
        query_name: query_name,
        in_format: options.fetch(:in_format, :display_table),
        args: options.fetch(:args, {}),
      )
    end
  end

  def run_query(query_name:, in_format:, args: {})
    RubyPgExtras.run_query_base(
      query_name: query_name,
      conn: connection,
      exec_method: :execute,
      in_format: in_format,
      args: args,
    )
  end

  def diagnose(in_format: :display_table)
    data = RailsPgExtras::DiagnoseData.call

    if in_format == :display_table
      RailsPgExtras::DiagnosePrint.call(data)
    elsif in_format == :hash
      data
    else
      raise "Invalid 'in_format' argument!"
    end
  end

  def measure_duration(&block)
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    block.call
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    (ending - starting) * 1000
  end

  def measure_queries(&block)
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
        duration = (finish - start) * 1000
        queries[key][:total_duration] += duration
        sql_duration += duration

        if queries[key][:min_duration] == nil || queries[key][:min_duration] > duration
          queries[key][:min_duration] = duration.round(2)
        end

        if queries[key][:max_duration] == nil || queries[key][:max_duration] < duration
          queries[key][:max_duration] = duration.round(2)
        end
      end
    end

    total_duration = measure_duration do
      block.call
    end

    queries = queries.reduce({}) do |agg, val|
      val[1][:avg_duration] = (val[1][:total_duration] / val[1][:count]).round(2)
      val[1][:total_duration] = val[1][:total_duration].round(2)
      agg.merge(val[0] => val[1])
    end

    ActiveSupport::Notifications.unsubscribe(subscriber)
    {
      count: queries.reduce(0) { |agg, val| agg + val[1].fetch(:count) },
      queries: queries,
      total_duration: total_duration.round(2),
      sql_duration: sql_duration.round(2),
    }
  end

  def index_info(args: {}, in_format: :display_table)
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

  def table_info(args: {}, in_format: :display_table)
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

  def missing_fk_indexes(args: {}, in_format: :display_table)
    result = RailsPgExtras::MissingFkIndexes.call(args[:table_name])
    RubyPgExtras.display_result(result, title: "Missing foreign key indexes", in_format: in_format)
  end

  def missing_fk_constraints(args: {}, in_format: :display_table)
    ignore_list = args[:ignore_list]
    ignore_list ||= RailsPgExtras.configuration.missing_fk_constraints_ignore_list
    result = RailsPgExtras::MissingFkConstraints.call(args[:table_name], ignore_list: ignore_list)
    RubyPgExtras.display_result(result, title: "Missing foreign key constraints", in_format: in_format)
  end

  def database_config
    @@database_config
  end

  # Deprecated
  alias_method :database_url, :database_config

  def database_config=(value)
    @@database_config = value
  end

  # Deprecated
  alias_method :database_url=, :database_config=

  def connection
    # Priority:
    # 1) Per-request selected db (thread-local), if present -> use named configuration or URL without altering global Base
    # 2) Explicit config via setter or ENV override
    # 3) Default ActiveRecord::Base connection
    selected_db_key = Thread.current[:rails_pg_extras_db_key]
    config = @@database_config || ENV["RAILS_PG_EXTRAS_DATABASE_CONFIG"] || ENV["RAILS_PG_EXTRAS_DATABASE_URL"] # Latter is deprecated

    if selected_db_key.present?
      # Prefix thread class key to avoid collisions
      ar_class = fetch_or_define_ar_class(thread_class_key: "database_#{selected_db_key}", const_name: selected_db_key.classify)

      establish_connection(ar_class: ar_class, config: selected_db_key.to_sym)
    elsif config.present?
      ar_class = fetch_or_define_ar_class(thread_class_key: :database_config, const_name: :PgExtrasDatabaseConfig)

      establish_connection(ar_class: ar_class, config: config)
    else
      ActiveRecord::Base.connection
    end
  end

  private

  # Use an isolated abstract class to avoid changing the global connection
  def fetch_or_define_ar_class(thread_class_key:, const_name:)
    thread_classes = Thread.current[:rails_pg_extras_ar_classes] ||= {}

    thread_classes[thread_class_key] ||=
      if const_defined?(const_name, false)
        const_get(const_name, false)
      else
        klass = Class.new(ActiveRecord::Base)
        klass.abstract_class = true

        const_set(const_name, klass)
      end
  end

  def establish_connection(ar_class:, config:)
    connector = ar_class.establish_connection(config)

    if connector.respond_to?(:connection)
      connector.connection
    elsif connector.respond_to?(:lease_connection)
      connector.lease_connection
    else
      raise "Unsupported connector: #{connector.class}"
    end
  end
end

require "rails_pg_extras/web"
require "rails_pg_extras/configuration"
require "rails_pg_extras/railtie" if defined?(Rails)
