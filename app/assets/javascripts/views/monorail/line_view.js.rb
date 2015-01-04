require 'vienna'

module Monorail
  class LineView < Vienna::View
    tag_name :line

    def create_element
      el = SVGElement.new(tag_name)
      # Fat, transparent line to catch clicks
      el['stroke-width'] = 10
      el[:stroke] = :transparent
      el[:x1] = coords[:x1]
      el[:y1] = coords[:y1]
      el[:x2] = coords[:x2]
      el[:y2] = coords[:y2]
      el.append_to parent.element
    end

    def create_line_element
      el = SVGElement.new(tag_name)
      # Narrow line to show the actual stroke
      el['stroke-width'] = 3
      el['stroke-linecap'] = :round
      el[:x1] = coords[:x1]
      el[:y1] = coords[:y1]
      el[:x2] = coords[:x2]
      el[:y2] = coords[:y2]
      el.append_to parent.element
    end

    def line_element
      @line_element ||= create_line_element
    end

    attr_accessor :model, :coords

    def initialize(parent, coords)
      self.model = Line.new
      self.parent = parent
      self.coords = coords
      line_element
      element # Add this second so that the click target will be on top of the stroke.
    end

    def render
      line_element[:stroke] = model.present? ? :black : nil
    end

    on :click do |evt|
      evt.prevent
      model.present? = model.present? ? nil : true
      render
    end
  end
end
