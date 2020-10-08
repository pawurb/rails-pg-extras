# frozen_string_literal: true

require 'rails-pg-extras'

namespace :pg_extras do
  desc "Establish connection"
  task :establish_connection do
    db_config_file = File.open('config/database.yml')
    db_config = YAML::load(db_config_file)
    ActiveRecord::Base.establish_connection(db_config[Rails.env])
  end

  RailsPGExtras::QUERIES.each do |query_name|
    desc RubyPGExtras.description_for(query_name: query_name)
    task query_name.to_sym => :establish_connection do
      RailsPGExtras.public_send(query_name)
    end
  end
end
