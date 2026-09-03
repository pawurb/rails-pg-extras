module RailsPgExtras::Web
  class QueriesController < RailsPgExtras::Web::ApplicationController
    before_action :load_queries
    helper_method :unavailable_extensions

    def index
      @query_name = params[:query_name].presence&.to_sym&.presence_in(@all_queries.keys)

      # An unknown query name falls back to the diagnose report.
      return load_diagnoses unless @query_name

      begin
        @result = RailsPgExtras.run_query(query_name: @query_name, in_format: :raw)
      rescue ActiveRecord::StatementInvalid => e
        @error = e.message
      end

      render :show
    end

    private

    SKIP_QUERIES = %i[table_schema table_foreign_keys].freeze

    def load_queries
      @all_queries = (RailsPgExtras::QUERIES - RailsPgExtras::Web::ACTIONS - SKIP_QUERIES).inject({}) do |memo, query_name|
        unless query_name.in? %i[mandelbrot]
          memo[query_name] = { disabled: query_disabled?(query_name) }
        end

        memo
      end
    end

    def load_diagnoses
      @diagnoses = RailsPgExtras.diagnose(in_format: :hash).sort_by { |d| d[:ok] ? 1 : 0 }
      @diagnose_pass_count = @diagnoses.count { |d| d[:ok] }
      @diagnose_fail_count = @diagnoses.size - @diagnose_pass_count
    rescue => e
      @diagnose_error = e.message
    end

    def query_disabled?(query_name)
      unavailable_extensions.values.flatten.include?(query_name)
    end

    def unavailable_extensions
      return @unavailable_extensions if defined?(@unavailable_extensions)

      enabled_extensions = RailsPgExtras.connection.extensions.lazy
      @unavailable_extensions = REQUIRED_EXTENSIONS.delete_if { |ext| enabled_extensions.grep(/^([^.]+\.)?#{ext}$/).any? }
    end
  end
end
