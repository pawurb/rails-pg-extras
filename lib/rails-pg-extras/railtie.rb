# frozen_string_literal: true

class RailsPGExtras::Railtie < Rails::Railtie
  rake_tasks do
    load 'rails-pg-extras/tasks/all.rake'
  end
end
