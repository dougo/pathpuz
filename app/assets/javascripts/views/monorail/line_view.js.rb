require 'vienna'

module Monorail
  class LineView < Vienna::View
    tag_name :line

    def create_element
      el = SVGElement.new(tag_name)
      el['stroke-width'] = 3
      el[:x1] = coords[:x1]
      el[:y1] = coords[:y1]
      el[:x2] = coords[:x2]
      el[:y2] = coords[:y2]
      el.append_to parent.element
    end

    attr_accessor :model, :coords

    def initialize(parent, coords)
      self.model = Line.new
      self.parent = parent
      self.coords = coords
    end

    def render
      element[:stroke] = model.present? ? :black : :transparent
    end

    on :click do
      model.present? = model.present? ? nil : true
      render
    end
  end
end
