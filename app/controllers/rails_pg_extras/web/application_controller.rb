require "rails-pg-extras"
require "rails_pg_extras/version"

module RailsPgExtras::Web
  class ApplicationController < ActionController::Base
    before_action :validate_credentials!
    before_action :set_databases
    layout "rails_pg_extras/web/application"

    REQUIRED_EXTENSIONS = {
      pg_stat_statements: %i[calls outliers pg_stat_statements_reset],
      pg_buffercache: %i[buffercache_stats buffercache_usage],
      sslinfo: %i[ssl_used]
    }

    ACTIONS = %i[kill_all pg_stat_statements_reset add_extensions]

    if ENV['RAILS_PG_EXTRAS_USER'].present? && ENV['RAILS_PG_EXTRAS_PASSWORD'].present?
      http_basic_authenticate_with name: ENV.fetch('RAILS_PG_EXTRAS_USER'), password: ENV.fetch('RAILS_PG_EXTRAS_PASSWORD')
    end

    def validate_credentials!
      if (ENV['RAILS_PG_EXTRAS_USER'].blank? || ENV['RAILS_PG_EXTRAS_PASSWORD'].blank?) && !RailsPgExtras.configuration.public_dashboard
        raise "Missing credentials for rails-pg-extras dashboard! If you want to enable public dashboard please set RAILS_PG_EXTRAS_PUBLIC_DASHBOARD=true"
      end
    end

    def set_databases
      @databases = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).map(&:name)
      set_current_database(@databases.first) if current_database.blank?
    end

    def set_current_database(database)
      ENV[RailsPgExtras::RAILS_PG_EXTRAS_DATABASE] = database
    end

    def current_database
      @current_database ||= ENV[RailsPgExtras::RAILS_PG_EXTRAS_DATABASE]
    end
  end
end
