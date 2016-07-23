require 'vienna'

module Monorail
  class HintRuleView < Vienna::View
    attr_reader :model

    tag_name :label

    def initialize(model)
      @model = model
      model.add_observer(:disabled) { render }
    end

    def render
      element.empty.text('Complete a completable dot')
      element.prepend Element.new(:input).attr(:type, :checkbox).prop(:checked, !model.disabled)
      self
    end

    on(:change, ':checkbox') do |evt|
      model.disabled = !evt.target.prop(:checked)
    end
  end
end
