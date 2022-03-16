require 'rails'

module RailsPgExtras::Web
  class Engine < ::Rails::Engine
    isolate_namespace RailsPgExtras::Web

    config.middleware.use ActionDispatch::Flash
  end
end
