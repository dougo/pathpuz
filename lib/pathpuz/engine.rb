require 'haml-rails'
require 'opal-rails'
require 'opal-haml'
require 'opal-vienna'

module Pathpuz
  class Engine < Rails::Engine
    isolate_namespace Pathpuz

    # Don't eager-load the .js.rb files in app/assets!
    config.eager_load_paths -= ["#{root}/app/assets"]
  end
end
