module RailsPgExtras::Web
  class ActionsController < RailsPgExtras::Web::ApplicationController
    before_action :validate_action!

    def kill_all
      run(:kill_all)
    end

    def pg_stat_statements_reset
      run(:pg_stat_statements_reset)
    end

    def add_extensions
      run(:add_extensions)
    end

    def switch_database
      set_current_database(params[:database])
      redirect_to request.env["HTTP_REFERER"]
    end

    private

    def validate_action!
      unless RailsPgExtras::Web.action_enabled?(action_name)
        render plain: "Action '#{action_name}' is not enabled!", status: :forbidden
      end
    end

    def run(action)
      begin
        RailsPgExtras.run_query(query_name: action, in_format: :raw)
        redirect_to root_path, notice: "Successfully ran #{action}"
      rescue ActiveRecord::StatementInvalid => e
        redirect_to root_path, alert: "Error: #{e.message}"
      end
    end
  end
end
