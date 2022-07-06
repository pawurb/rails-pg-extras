# frozen_string_literal: true

require 'rails-pg-extras'

namespace :pg_extras do
  task :establish_connection do
    if ENV['DATABASE_URL'].present?
      ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
    else
      db_config_file = File.read('config/database.yml')
      db_config = YAML.safe_load(ERB.new(db_config_file).result, aliases: true)
      ActiveRecord::Base.establish_connection(db_config[Rails.env])
    end
  end

  RailsPgExtras::QUERIES.each do |query_name|
    desc RubyPgExtras.description_for(query_name: query_name)
    task query_name.to_sym => :establish_connection do
      RailsPgExtras.public_send(query_name)
    end
  end

  desc "Generate a PostgreSQL healthcheck report"
  task diagnose: :establish_connection do
    RailsPgExtras.diagnose
  end

  desc "Display tables metadata metrics"
  task table_info: :establish_connection do
    RailsPgExtras.table_info
  end

  desc "Display indexes metadata metrics"
  task index_info: :establish_connection do
    RailsPgExtras.index_info
  end
end
