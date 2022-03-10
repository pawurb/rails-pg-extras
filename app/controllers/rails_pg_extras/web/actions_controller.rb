module RailsPgExtras::Web
  class ActionsController < RailsPgExtras::Web::ApplicationController
    def kill_all
      run(:kill_all)
    end

    def pg_stat_statements_reset
      run(:pg_stat_statements_reset)
    end

    def add_extensions
      run(:add_extensions)
    end

    private

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
