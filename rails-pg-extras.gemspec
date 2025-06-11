# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rails_pg_extras/version"

Gem::Specification.new do |s|
  s.name = "rails-pg-extras"
  s.version = RailsPgExtras::VERSION
  s.authors = ["pawurb"]
  s.email = ["contact@pawelurbanek.com"]
  s.summary = %q{ Rails PostgreSQL performance database insights }
  s.description = %q{ Rails port of Heroku PG Extras. The goal of this project is to provide a powerful insights into PostgreSQL database for Ruby on Rails apps that are not using the default Heroku PostgreSQL plugin. }
  s.homepage = "http://github.com/pawurb/rails-pg-extras"
  s.files = `git ls-files`.split("\n")
  s.test_files = s.files.grep(%r{^(spec)/})
  s.require_paths = ["lib"]
  s.license = "MIT"
  s.add_dependency "ruby-pg-extras", RailsPgExtras::VERSION
  s.add_dependency "rails"
  s.add_dependency "fast-mcp"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rufo"

  if s.respond_to?(:metadata=)
    s.metadata = { "rubygems_mfa_required" => "true" }
  end
end
