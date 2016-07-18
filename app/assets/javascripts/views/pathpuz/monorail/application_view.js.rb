require 'vienna'

module Monorail
  class ApplicationView < Vienna::View
    attr_accessor :model

    element '#puzzle'

    def initialize(model)
      self.model = model
      model.add_observer(:puzzle) { render }
    end

    def render
      element.empty << render_instructions << render_puzzle << render_autohint << render_buttons
      self
    end

    on(:click, '.prev') { model.prev_puzzle! }
    on(:click, '.next') { model.next_puzzle! }

    private

    def render_instructions
      Element.new(:p).text('Build a monorail loop that visits every dot.')
    end

    def render_puzzle
      PuzzleView.new(model.puzzle).render.element
    end

    def render_autohint
      AutohintView.new(model).render.element
    end

    def render_buttons
      prev = Element.new(:button).add_class('prev').text('Previous puzzle').prop(:disabled, model.puzzle.id.zero?)
      undo = UndoButtonView.new(model.puzzle).render.element
      hint = HintButtonView.new(model.puzzle).render.element
      nexx = Element.new(:button).add_class('next').text('Next puzzle')
      Element.new << prev << undo << hint << nexx
    end
  end
end
