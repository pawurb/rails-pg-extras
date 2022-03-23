module RailsPgExtras::Web
  class QueriesController < RailsPgExtras::Web::ApplicationController
    before_action :load_queries
    helper_method :unavailable_extensions

    def index
      if params[:query_name].present?
        @query_name = params[:query_name].to_sym.presence_in(@all_queries.keys)
        return unless @query_name

        begin
          @result = RailsPgExtras.run_query(query_name: @query_name.to_sym, in_format: :raw)
        rescue ActiveRecord::StatementInvalid => e
          @error = e.message
        end

        render :show
      end
    end

    private

    def load_queries
      @all_queries = (RailsPgExtras::QUERIES - RailsPgExtras::Web::ACTIONS).inject({}) do |memo, query_name|
        unless query_name.in? %i[mandelbrot]
          memo[query_name] = { disabled: query_disabled?(query_name) }
        end

        memo
      end
    end

    def query_disabled?(query_name)
      unavailable_extensions.values.flatten.include?(query_name)
    end

    def unavailable_extensions
      return @unavailable_extensions if defined?(@unavailable_extensions)

      enabled_extensions = ActiveRecord::Base.connection.extensions
      @unavailable_extensions = REQUIRED_EXTENSIONS.delete_if { |ext| ext.to_s.in?(enabled_extensions)  }
    end
  end
end
