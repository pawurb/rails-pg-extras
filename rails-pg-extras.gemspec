# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-pg-extras/version'

Gem::Specification.new do |gem|
  gem.name          = "rails-pg-extras"
  gem.version       = RailsPGExtras::VERSION
  gem.authors       = ["pawurb"]
  gem.email         = ["contact@pawelurbanek.com"]
  gem.summary       = %q{ Rails PostgreSQL database insights }
  gem.description   = %q{ A bunch of rake tasks for showing what's going on inside your Rails PostgreSQL database }
  gem.homepage      = "http://github.com/pawurb/rails-pg-extras"
  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ["lib"]
  gem.license       = "MIT"
  gem.add_dependency "activerecord"
  gem.add_dependency "terminal-table"
end
