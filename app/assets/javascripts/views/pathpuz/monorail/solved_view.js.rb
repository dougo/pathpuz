require 'vienna'

module Monorail
  class SolvedView < Vienna::View
    attr_accessor :model

    tag_name :g

    def initialize(model)
      self.model = model
    end

    def create_element
      SVGElement.new(tag_name)
    end

    def render
      if model.solved?
        # Cover the grid with a transparent rectangle to catch/ignore all clicks.
        rect = SVGElement.new(:rect)
        rect[:x] = -1
        rect[:y] = -1
        rect[:width] = '100%'
        rect[:height] = '100%'
        rect[:fill] = :transparent
        element.append(rect)
      end
      self
    end
  end
end
