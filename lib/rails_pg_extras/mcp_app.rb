# frozen_string_literal: true

require "fast_mcp"
require "rack"
require "rails_pg_extras/version"

SKIP_QUERIES = %i[
  add_extensions
  pg_stat_statements_reset
  kill_pid
  kill_all
  mandelbrot
]

QUERY_TOOL_CLASSES = RubyPgExtras::QUERIES.reject { |q| SKIP_QUERIES.include?(q) }.map do |query_name|
  Class.new(FastMcp::Tool) do
    description RubyPgExtras.description_for(query_name: query_name)

    define_method :call do
      RailsPgExtras.public_send(query_name, in_format: :hash)
    end

    define_singleton_method :name do
      query_name.to_s
    end
  end
end

class MissingFkConstraintsTool < FastMcp::Tool
  description "Shows missing foreign key constraints"

  def call
    RailsPgExtras.missing_fk_constraints(in_format: :hash)
  end

  def self.name
    "missing_fk_constraints"
  end
end

class MissingFkIndexesTool < FastMcp::Tool
  description "Shows missing foreign key indexes"

  def call
    RailsPgExtras.missing_fk_indexes(in_format: :hash)
  end

  def self.name
    "missing_fk_indexes"
  end
end

class DiagnoseTool < FastMcp::Tool
  description "Performs a health check of the database"

  def call
    RailsPgExtras.diagnose(in_format: :hash)
  end

  def self.name
    "diagnose"
  end
end

class ReadmeResource < FastMcp::Resource
  uri "file://README.md"
  resource_name "README"
  description "The README for RailsPgExtras"
  mime_type "text/plain"

  def content
    File.read(uri)
  end
end

module RailsPgExtras
  class MCPApp
    def self.build
      app = lambda do |_env|
        [200, { "Content-Type" => "text/html" },
         ["<html><body><h1>Hello from Rack!</h1><p>This is a simple Rack app with MCP middleware.</p></body></html>"]]
      end

      # Create the MCP middleware
      mcp_app = FastMcp.rack_middleware(
        app,
        name: "rails-pg-extras", version: RailsPgExtras::VERSION,
        path_prefix: "/pg-extras-mcp",
        logger: Logger.new($stdout),
      ) do |server|
        server.register_tools(DiagnoseTool)
        server.register_tools(MissingFkConstraintsTool)
        server.register_tools(MissingFkIndexesTool)
        server.register_tools(*QUERY_TOOL_CLASSES)

        server.register_resource(ReadmeResource)

        Rack::Builder.new { run mcp_app }
      end
    end
  end
end
