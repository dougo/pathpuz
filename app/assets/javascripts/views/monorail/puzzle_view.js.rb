require 'vienna'

module Monorail
  class PuzzleView < Vienna::View
    attr_accessor :model, :svg

    def initialize(model)
      self.model = model
    end

    def render
      element.append Element.new(:p).text('Build a monorail loop that visits every dot.')
      self.svg = SVGView.new(self)
      svg.render
    end
  end
end
