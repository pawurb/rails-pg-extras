# frozen_string_literal: true

class RailsPgExtras::Railtie < Rails::Railtie
  rake_tasks do
    load 'rails_pg_extras/tasks/all.rake'
  end
end
