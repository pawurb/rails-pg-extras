# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'active_record'
require_relative '../lib/rails_pg_extras'

pg_version = ENV["PG_VERSION"]

port = if pg_version == "11"
  "5432"
elsif pg_version == "12"
  "5433"
elsif pg_version == "13"
  "5434"
else
  "5432"
end

ENV["DATABASE_URL"] ||= "postgresql://postgres:secret@localhost:#{port}/rails-pg-extras-test"

RSpec.configure do |config|
  config.before :suite do
    ActiveRecord::Base.establish_connection(
      ENV.fetch("DATABASE_URL")
    )
    RailsPgExtras.connection.execute("CREATE EXTENSION IF NOT EXISTS pg_stat_statements;")
    RailsPgExtras.connection.execute("CREATE EXTENSION IF NOT EXISTS pg_buffercache;")
    RailsPgExtras.connection.execute("CREATE EXTENSION IF NOT EXISTS sslinfo;")
  end

  config.after :suite do
    ActiveRecord::Base.remove_connection
  end
end
