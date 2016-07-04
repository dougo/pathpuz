require 'jquery'
require 'opal-jquery'
require 'opal-haml'

require 'active_support/testing/declarative'

class Minitest::Test
  # Add the 'test' DSL.
  extend ActiveSupport::Testing::Declarative
end

# TODO: get this from the environment? I don't know why Opal doesn't set this...
Encoding.default_external = 'UTF-8'
