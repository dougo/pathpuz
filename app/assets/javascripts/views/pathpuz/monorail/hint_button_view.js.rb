require 'vienna'

module Monorail
  class HintButtonView < Vienna::View
    attr_accessor :model

    tag_name :button

    def initialize(model)
      self.model = model
      model.on(:lines_changed) { render }
      model.on(:undone) { render }
    end

    def render
      element.text('Hint').prop(:disabled, !model.can_hint? || model.solved?)
      self
    end

    on(:click) { model.hint! }
  end
end
