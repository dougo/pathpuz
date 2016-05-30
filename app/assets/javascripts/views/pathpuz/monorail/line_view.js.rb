require 'vienna'

module Monorail
  class LineView < Vienna::View
    tag_name :g

    attr_accessor :model, :clickable_element, :line_element

    def initialize(model)
      self.model = model
      model.add_observer(:present?) { render }
    end

    def create_element
      el = SVGElement.new(tag_name)
      self.clickable_element = create_clickable_element unless model.fixed?
      self.line_element = create_line_element
      el.append(line_element).append(clickable_element)
    end

    def render
      element
      line_element[:stroke] = stroke
      self
    end

    on :click, '[cursor=pointer]' do |evt|
      model.present? = model.present? ? nil : true
    end

    private

    def create_clickable_element
      el = SVGElement.new(:line)
      # Fat, transparent line to catch clicks
      el['stroke-width'] = 0.3
      el[:stroke] = :transparent
      el[:cursor] = :pointer
      init_coords(el)
    end

    def create_line_element
      el = SVGElement.new(:line)
      # Narrow line to show the actual stroke
      el['stroke-width'] = 0.1
      el['stroke-linecap'] = :round
      el[:stroke] = :gray if model.fixed?
      init_coords(el)
    end

    def init_coords(el)
      el[:x1] = model.dot1.col
      el[:y1] = model.dot1.row
      el[:x2] = model.dot2.col
      el[:y2] = model.dot2.row
    end

    def stroke
      if model.present?
        model.fixed? ? :gray : :black
      end
    end
  end
end
