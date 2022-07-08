# frozen_string_literal: true

require 'rails-pg-extras'

namespace :pg_extras do
  RailsPgExtras::QUERIES.each do |query_name|
    desc RubyPgExtras.description_for(query_name: query_name)
    task query_name.to_sym => :environment do
      RailsPgExtras.public_send(query_name)
    end
  end

  desc "Generate a PostgreSQL healthcheck report"
  task diagnose: :environment do
    RailsPgExtras.diagnose
  end

  desc "Display tables metadata metrics"
  task table_info: :environment do
    RailsPgExtras.table_info
  end

  desc "Display indexes metadata metrics"
  task index_info: :environment do
    RailsPgExtras.index_info
  end
end
