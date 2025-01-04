require "rails-pg-extras"
require "rails_pg_extras/version"

module RailsPgExtras::Web
  class ApplicationController < ActionController::Base
    before_action :validate_credentials!
    layout "rails_pg_extras/web/application"

    REQUIRED_EXTENSIONS = {
      pg_stat_statements: %i[calls outliers pg_stat_statements_reset],
      pg_buffercache: %i[buffercache_stats buffercache_usage],
      sslinfo: %i[ssl_used],
    }

    ACTIONS = %i[kill_all pg_stat_statements_reset add_extensions]

    user = get_user
    password = get_password

    if user.present? && password.present?
      http_basic_authenticate_with name: user, password: password
    end

    def validate_credentials!
      if (get_user.blank? || get_password.blank?) && RailsPgExtras.configuration.public_dashboard != true
        raise "Missing credentials for rails-pg-extras dashboard! If you want to enable public dashboard please set RAILS_PG_EXTRAS_PUBLIC_DASHBOARD=true"
      end
    end

    private

    def get_user
      Rails.application.try(:credentials).try(:pg_extras).try(:user) || ENV["RAILS_PG_EXTRAS_USER"]
    end

    def get_password
      Rails.application.try(:credentials).try(:pg_extras).try(:password) || ENV["RAILS_PG_EXTRAS_PASSWORD"]
    end
  end
end
