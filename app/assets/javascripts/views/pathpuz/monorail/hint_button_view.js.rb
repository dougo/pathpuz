require 'vienna'

module Monorail
  class HintButtonView < Vienna::View
    attr_accessor :model

    tag_name :button

    def initialize(model)
      self.model = model
      model.puzzle.on(:lines_changed) { render }
      model.puzzle.on(:undone) { render }
    end

    def render
      element.text('Hint').prop(:disabled, !model.can_hint? || model.puzzle.solved?)
      self
    end

    on(:click) { model.hint! }
  end
end
