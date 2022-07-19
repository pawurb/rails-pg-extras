require "rails-pg-extras"
require "rails_pg_extras/version"

module RailsPgExtras::Web
  class ApplicationController < ActionController::Base
    layout "rails_pg_extras/web/application"

    REQUIRED_EXTENSIONS = {
      pg_stat_statements: %i[calls outliers pg_stat_statements_reset],
      pg_buffercache: %i[buffercache_stats buffercache_usage],
      sslinfo: %i[ssl_used]
    }

    ACTIONS = %i[kill_all pg_stat_statements_reset add_extensions]

    if Rails.env.production? && (ENV['RAILS_PG_EXTRAS_USER'].blank? || ENV['RAILS_PG_EXTRAS_PASSWORD'].blank?) && ENV["RAILS_PG_EXTRAS_PUBLIC_DASHBOARD"] != "true"
      raise "Missing credentials for rails-pg-extras dashboard!"
    end

    if ENV['RAILS_PG_EXTRAS_USER'].present? && ENV['RAILS_PG_EXTRAS_PASSWORD'].present?
      http_basic_authenticate_with name: ENV.fetch('RAILS_PG_EXTRAS_USER'), password: ENV.fetch('RAILS_PG_EXTRAS_PASSWORD')
    end
  end
end
