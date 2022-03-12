# frozen_string_literal: true

require "rails_pg_extras/web"

module RailsPgExtras
  class Configuration
    DEFAULT_CONFIG = { enabled_web_actions: Web::ACTIONS }

    attr_reader :enabled_web_actions

    def initialize(attrs)
      self.enabled_web_actions = attrs[:enabled_web_actions]
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