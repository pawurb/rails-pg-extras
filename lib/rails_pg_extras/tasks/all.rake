# frozen_string_literal: true

require 'rails-pg-extras'

namespace :pg_extras do
  RailsPgExtras::QUERIES.each do |query_name|
    desc RubyPgExtras.description_for(query_name: query_name)
    task query_name.to_sym, [:db_name] => :environment do |_, args|
      if RailsPgExtras.connections
        RailsPgExtras.connections.each { |x| x.reconnect! } 
      end
      RailsPgExtras.public_send(query_name, db_name: args[:db_name])
    end
  end

  desc "Generate a PostgreSQL healthcheck report"
  task :diagnose, [:db_name] => :environment do |_, args|
    if RailsPgExtras.connections
      RailsPgExtras.connections.each { |x| x.reconnect! } 
    end
    RailsPgExtras.diagnose(db_name: args[:db_name])
  end

  desc "Display tables metadata metrics"
  task :table_info, [:db_name] => :environment do |_, args|
    if RailsPgExtras.connections
      RailsPgExtras.connections.each { |x| x.reconnect! } 
    end
    RailsPgExtras.table_info(db_name: args[:db_name])
  end

  desc "Display indexes metadata metrics"
  task :index_info, [:db_name] => :environment do |_, args|
    if RailsPgExtras.connections
      RailsPgExtras.connections.each { |x| x.reconnect! } 
    end
    RailsPgExtras.index_info(db_name: args[:db_name])
  end
end
