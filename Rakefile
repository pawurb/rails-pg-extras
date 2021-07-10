require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Test all PG versions'
task :test_all do
  system("PG_VERSION=11 bundle exec rspec spec/ && PG_VERSION=12 bundle exec rspec spec/ && PG_VERSION=13 bundle exec rspec spec/")
end

