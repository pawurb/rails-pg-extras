require "rails"

module RailsPgExtras::Web
  class Engine < ::Rails::Engine
    isolate_namespace RailsPgExtras::Web
    config.middleware.use ActionDispatch::Flash
    initializer "static assets" do |app|
      app.middleware.insert_before(0, ::ActionDispatch::Static, "#{RailsPgExtras::Web::Engine.root}/assets")
    end
  end
end
