# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'active_record'
require_relative '../lib/rails-pg-extras'

ENV["DATABASE_URL"] ||= "postgresql://postgres:secret@localhost:5432/rails-pg-extras-test"

RSpec.configure do |config|
  config.before :suite do
    ActiveRecord::Base.establish_connection(
      ENV.fetch("DATABASE_URL")
    ).tap do |pg|
      pg.connection.execute("CREATE EXTENSION IF NOT EXISTS pg_stat_statements;")
    end
  end

  config.after :suite do
    ActiveRecord::Base.remove_connection
  end
end
