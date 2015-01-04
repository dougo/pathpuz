require 'vienna'

module Monorail
  class LineView < Vienna::View
    tag_name :line

    def create_element
      el = SVGElement.new(tag_name)
      el.append_to parent.element
    end

    attr_accessor :coords

    def initialize(parent, coords)
      self.parent = parent
      self.coords = coords
    end

    def render
      element[:stroke] = :transparent
      element['stroke-width'] = 3
      element[:x1] = coords[:x1]
      element[:y1] = coords[:y1]
      element[:x2] = coords[:x2]
      element[:y2] = coords[:y2]
    end

    on :click do
      if element[:stroke] == :transparent
        element[:stroke] = :black
      else
        element[:stroke] = :transparent
      end
    end
  end
end
