require "rails_pg_extras/web/engine"

module RailsPgExtras
  module Web
    ACTIONS = %i[kill_all pg_stat_statements_reset add_extensions].freeze

    def self.action_enabled?(action_name)
      RailsPgExtras.configuration.enabled_web_actions.include?(action_name.to_sym)
    end
  end
end
