require 'vienna'

module Monorail
  class HintRuleView < Vienna::View
    attr_reader :model

    tag_name :tr

    def initialize(model)
      @model = model
      model.add_observer(:auto) { render }
    end

    def render
      label = Element.new(:label).text(name).attr(:for, model.type)
      checkbox = Element.new(:input).attr(:type, :checkbox).prop(:checked, !!model.auto)
      checkbox.id = model.type
      element.empty << Element.new(:td).append(label) << Element.new(:td).append(checkbox)
      self
    end

    on(:change, ':checkbox') do |evt|
      model.auto = evt.target.prop(:checked)
    end

    private

    def name
      case model.type
      when :every_dot_has_two_lines
        'Every dot has two lines'
      when :every_dot_has_only_two_lines
        'Every dot has only two lines'
      when :short_loop_line
        "Don't close a short loop with a line"
      when :short_loop_dot
        "Don't close a short loop with two lines"
      end
    end
  end
end
