require 'vienna'

module Monorail
  class PuzzleView < Vienna::View
    attr_accessor :model, :svg

    def initialize(model)
      self.model = model
    end

    def render
      element.empty
      element.append Element.new(:p).text('Build a monorail loop that visits every dot.')
      self.svg = SVGView.new(self)
      svg.render
      next_button = Element.new(:button).text('Next puzzle')
      element.append Element.new(:p).append next_button
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
