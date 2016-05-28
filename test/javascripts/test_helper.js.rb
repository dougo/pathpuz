# TODO: this require causes a warning, but removing it causes an error...
require 'jquery'

require 'opal-jquery'
require 'opal-haml'

require 'active_support/testing/declarative'

class Minitest::Test
  # Add the 'test' DSL.
  extend ActiveSupport::Testing::Declarative
end
