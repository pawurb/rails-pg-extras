module RailsPgExtras::Web
  class ActionsController < RailsPgExtras::Web::ApplicationController
    before_action :validate_action!

    def kill_all
      run(:kill_all, db_name: params[:db_name])
    end

    def pg_stat_statements_reset
      run(:pg_stat_statements_reset, db_name: params[:db_name])
    end

    def add_extensions
      run(:add_extensions, db_name: params[:db_name])
    end

    private

    def validate_action!
      unless RailsPgExtras::Web.action_enabled?(action_name)
        render plain: "Action '#{action_name}' is not enabled!", status: :forbidden
      end
    end

    def run(action, db_name: nil)
      begin
        RailsPgExtras.run_query(query_name: action, db_name: db_name, in_format: :raw)
        redirect_to root_path, notice: "Successfully ran #{action}#{" for database #{db_name}" if db_name.present?}"
      rescue ActiveRecord::StatementInvalid => e
        redirect_to root_path, alert: "Error: #{e.message}"
      end
    end
  end
end
