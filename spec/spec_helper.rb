# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "active_record"
require_relative "../lib/rails-pg-extras"

pg_version = ENV["PG_VERSION"]

PG_PORTS = {
  "13" => "5433",
  "14" => "5434",
  "15" => "5435",
  "16" => "5436",
  "17" => "5437",
  "18" => "5438",
}

port = PG_PORTS.fetch(pg_version, "5438")

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
