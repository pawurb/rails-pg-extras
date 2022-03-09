require 'rails'

module RailsPgExtras::Web
  class Engine < ::Rails::Engine
    isolate_namespace RailsPgExtras::Web
  end
end
