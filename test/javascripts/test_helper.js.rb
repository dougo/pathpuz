require 'jquery'
require 'opal-jquery'

require 'active_support/testing/declarative'

class Minitest::Test
  # Add the 'test' DSL.
  extend ActiveSupport::Testing::Declarative
end
