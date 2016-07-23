require 'vienna'

module Monorail
  class HintRuleView < Vienna::View
    attr_reader :model

    def initialize(model)
      @model = model
      model.add_observer(:disabled) { render }
    end

    def render
      checkbox = Element.new(:input).attr(:type, :checkbox).prop(:checked, !model.disabled)
      element.empty << Element.new(:label).text(name).prepend(checkbox)
      self
    end

    on(:change, ':checkbox') do |evt|
      model.disabled = !evt.target.prop(:checked)
    end

    private

    def name
      case model.type
      when :every_dot_has_two_lines
        'Every dot has two lines'
      when :every_dot_has_only_two_lines
        'Every dot has only two lines'
      end
    end
  end
end
