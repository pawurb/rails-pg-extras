# frozen_string_literal: true

require "rails_pg_extras/web"

module RailsPgExtras
  class Configuration
    DEFAULT_CONFIG = { enabled_web_actions: Web::ACTIONS - [:kill_all, :kill_pid], public_dashboard: ENV["RAILS_PG_EXTRAS_PUBLIC_DASHBOARD"] == "true", missing_fk_constraints_ignore_list: [], missing_fk_indexes_ignore_list: [] }

    attr_reader :enabled_web_actions
    attr_accessor :public_dashboard
    attr_accessor :missing_fk_constraints_ignore_list
    attr_accessor :missing_fk_indexes_ignore_list

    def initialize(attrs)
      self.enabled_web_actions = attrs[:enabled_web_actions]
      self.public_dashboard = attrs[:public_dashboard]
      self.missing_fk_constraints_ignore_list = attrs[:missing_fk_constraints_ignore_list]
      self.missing_fk_indexes_ignore_list = attrs[:missing_fk_indexes_ignore_list]
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
