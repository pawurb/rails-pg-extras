# frozen_string_literal: true

require 'rails-pg-extras'

namespace :pg_extras do
  task :establish_connection do
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Rails.env])
  end

  RailsPGExtras::QUERIES.each do |query_name|
    desc RubyPGExtras.description_for(query_name: query_name)
    task query_name.to_sym => :environment do
      RailsPGExtras.public_send(query_name)
    end
  end
end
