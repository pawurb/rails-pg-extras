# frozen_string_literal: true

require 'rails-pg-extras'

namespace :pg_extras do
  task :establish_connection do
    db_config_file = File.read('config/database.yml')
    db_config = YAML::load(ERB.new(db_config_file).result)
    ActiveRecord::Base.establish_connection(db_config[Rails.env])
  end

  RailsPGExtras::QUERIES.each do |query_name|
    desc RubyPGExtras.description_for(query_name: query_name)
    task query_name.to_sym => :environment do
      RailsPGExtras.public_send(query_name)
    end
  end
end
