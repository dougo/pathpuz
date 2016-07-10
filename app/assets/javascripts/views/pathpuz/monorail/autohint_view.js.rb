require 'vienna'

module Monorail
  class AutohintView < Vienna::View
    attr_accessor :model

    class_name :autohint

    def initialize(model)
      self.model = model
      model.add_observer(:autohint) { render }
    end

    def render
      checkbox = Element.new(:input).attr(:type, 'checkbox').prop(:checked, model.autohint)
      label = Element.new(:label).text('Auto-hint').prepend(checkbox)
      element.empty << label
      self
    end

    on(:change, ':checkbox') do |evt|
      model.autohint = evt.target.is(':checked')
    end
  end
end
