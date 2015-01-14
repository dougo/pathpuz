require 'vienna'

module Monorail
  class LineView < Vienna::View
    tag_name :line

    def create_element
      el = SVGElement.new(tag_name)
      # Fat, transparent line to catch clicks
      el['stroke-width'] = 0.3
      el[:stroke] = :transparent
      el[:cursor] = :pointer
      init_coords(el)
      el
    end

    def create_line_element
      el = SVGElement.new(tag_name)
      # Narrow line to show the actual stroke
      el['stroke-width'] = 0.1
      el['stroke-linecap'] = :round
      init_coords(el)
      el
    end

    def line_element
      @line_element ||= create_line_element
    end

    attr_accessor :model

    def initialize(model)
      self.model = model
      model.add_observer(:present?) { render }
    end

    def render
      line_element[:stroke] = model.present? ? :black : nil
    end

    on :click do |evt|
      model.present? = model.present? ? nil : true
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
