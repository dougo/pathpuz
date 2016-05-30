require 'turbolinks'
require 'haml-rails'
require 'opal-rails'
require 'opal-haml'
require 'opal-vienna'

module Pathpuz
  class Engine < Rails::Engine
    isolate_namespace Pathpuz
  end
end
