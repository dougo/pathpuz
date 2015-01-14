require 'vienna'

module Monorail
  class PuzzleView < Vienna::View
    attr_accessor :model, :svg, :solved

    def initialize(model)
      self.model = model
    end

    def render
      instructions = Element.new(:p).text('Build a monorail loop that visits every dot.')
      self.svg = SVGView.new(model)
      next_button = Element.new(:div).append(Element.new(:button).text('Next puzzle'))
      self.solved = SolvedView.new(model)

      element.empty
      element.append(instructions)
      element.append(svg.render.element)
      element.append(next_button)
      element.append(solved.render.element)
    end

    on :click, :button do
      self.model = Puzzle.new
    end

    def model=(model)
      prev_model = self.model
      @model = model
      render if prev_model
    end
  end
end
