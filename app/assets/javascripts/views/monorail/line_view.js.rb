require 'vienna'

module Monorail
  class LineView < Vienna::View
    tag_name :g

    attr_accessor :model, :clickable_element, :line_element

    def create_element
      el = SVGElement.new(tag_name)

      self.clickable_element = SVGElement.new(:line)
      # Fat, transparent line to catch clicks
      clickable_element['stroke-width'] = 0.3
      clickable_element[:stroke] = :transparent
      clickable_element[:cursor] = :pointer
      init_coords(clickable_element)

      self.line_element = SVGElement.new(:line)
      # Narrow line to show the actual stroke
      line_element['stroke-width'] = 0.1
      line_element['stroke-linecap'] = :round
      init_coords(line_element)

      el.append(line_element).append(clickable_element)
    end

    def initialize(model)
      self.model = model
      model.add_observer(:present?) { render }
    end

    def render
      element
      line_element[:stroke] = model.present? ? :black : nil
      self
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
