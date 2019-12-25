# frozen_string_literal: true

require 'rails-pg-extras'

namespace :pg_extras do
  RailsPGExtras::QUERIES.each do |query_name|
    desc RailsPGExtras.public_send("#{query_name}_description")
    task query_name.to_sym => :environment do
      RailsPGExtras.public_send(query_name)
    end
  end
end
