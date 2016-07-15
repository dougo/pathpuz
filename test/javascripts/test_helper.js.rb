require 'jquery'
require 'opal-jquery'
require 'opal-haml'

require 'active_support/testing/declarative'
require 'active_support/core_ext/class/attribute'

require 'pathpuz/application'

class Minitest::Test
  # Add the 'test' DSL.
  extend ActiveSupport::Testing::Declarative
end

class ViewTest < Minitest::Test
  class_attribute :model_class, :view_class

  def model
    @model ||= model_class.new
  end

  def view
    @view ||= view_class.new(model).render
  end

  def el
    @el ||= view.element
  end
end
