require 'vienna'

module Monorail
  class LineView < Vienna::View
    tag_name :line

    def create_element
      el = SVGElement.new(tag_name)
      # Fat, transparent line to catch clicks
      el['stroke-width'] = 0.4
      el[:stroke] = :transparent
      init_coords(el)
      el.append_to parent.element
    end

    def create_line_element
      el = SVGElement.new(tag_name)
      # Narrow line to show the actual stroke
      el['stroke-width'] = 0.12
      el['stroke-linecap'] = :round
      init_coords(el)
      el.append_to parent.element
    end

    def line_element
      @line_element ||= create_line_element
    end

    attr_accessor :model

    def initialize(model, parent)
      self.model = model
      self.parent = parent
    end

    def render
      line_element[:stroke] = model.present? ? :black : nil
      element # Add this second so that the click target will be on top of the stroke.
    end

    on :click do |evt|
      evt.prevent
      model.present? = model.present? ? nil : true
      render
    end

    private

    def init_coords(el)
      el[:x1] = model.dot1.col
      el[:y1] = model.dot1.row
      el[:x2] = model.dot2.col
      el[:y2] = model.dot2.row
    end
  end
end
