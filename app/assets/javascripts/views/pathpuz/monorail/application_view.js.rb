require 'vienna'

module Monorail
  class ApplicationView < Vienna::View
    attr_accessor :model, :puzzle

    element '#puzzle'

    def initialize(model)
      self.model = model

      model.add_observer(:puzzle) do |puzzle|
        render
      end
    end

    def render
      element.empty << render_instructions << render_puzzle << render_autohint << render_buttons
      self
    end

    private

    def render_instructions
      Element.new(:p).text('Build a monorail loop that visits every dot.')
    end

    def render_puzzle
      self.puzzle = PuzzleView.new(model.puzzle)
      puzzle.render.element
    end

    def render_autohint
      AutohintView.new(model).render.element
    end

    def render_buttons
      buttons = Element.new(:div)

      prev_button = Element.new(:button).text('Previous puzzle').prop(:disabled, model.puzzle.id.zero?)
      prev_button.on(:click) { model.prev_puzzle! }

      hint_button = HintButtonView.new(model).render

      next_button = Element.new(:button).text('Next puzzle')
      next_button.on(:click) { model.next_puzzle! }

      buttons << prev_button << hint_button.element << next_button
    end
  end
end
