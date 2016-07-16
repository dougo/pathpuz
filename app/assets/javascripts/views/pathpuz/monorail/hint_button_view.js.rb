require 'vienna'

module Monorail
  class HintButtonView < Vienna::View
    attr_accessor :model

    tag_name :button

    def initialize(model)
      self.model = model
      model.add_observer(:autohint) { render }
      model.puzzle.on(:solved) { render }
    end

    def render
      element.text('Hint').prop(:disabled, model.autohint || model.puzzle.solved?)
      self
    end

    on(:click) { model.puzzle.hint! }
  end
end
