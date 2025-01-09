# frozen_string_literal: true

require "rails_pg_extras/web"

module RailsPgExtras
  class Configuration
    DEFAULT_CONFIG = { enabled_web_actions: Web::ACTIONS - [:kill_all], public_dashboard: ENV["RAILS_PG_EXTRAS_PUBLIC_DASHBOARD"] == "true" }

    attr_reader :enabled_web_actions
    attr_accessor :public_dashboard
    attr_accessor :selected_database
    attr_accessor :show_all_active_record_databases

    def initialize(attrs)
      self.enabled_web_actions = attrs[:enabled_web_actions]
      self.public_dashboard = attrs[:public_dashboard]
    end

    def enabled_web_actions=(*actions)
      @enabled_web_actions = actions.flatten.map(&:to_sym)
    end
  end

  def self.configuration
    @configuration ||= Configuration.new(Configuration::DEFAULT_CONFIG)
  end

  def self.configure
    yield(configuration)
  end
end
