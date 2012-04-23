require File.expand_path('../boot', __FILE__)

#require "action_controller/railtie"
#require "action_mailer/railtie"
#require "active_resource/railtie"
#require "rails/test_unit/railtie"
require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module MindpinEduSns
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.assets.enabled = true
    config.assets.version = '1.0'

    config.autoload_paths += Dir["#{Rails.root}/lib/**/"]
    config.time_zone = 'UTC'
  end
end
