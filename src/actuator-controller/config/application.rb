require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"
require "net/http"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ActuatorsControl
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.enable_dependency_loading = true
    config.api_only = true
    config.autoload_paths << Rails.root.join('lib')

    # Avoid CORS issues when API is called from the frontend app.
    # Handle Cross-Origin BasicResource Sharing (CORS) in order to accept cross-origin AJAX requests.

    # Read more: https://github.com/cyu/rack-cors

    require 'rack/cors'
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'

        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
  end
end
