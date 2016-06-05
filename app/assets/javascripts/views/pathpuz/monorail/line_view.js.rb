require 'vienna'

module Monorail
  class LineView < Vienna::View
    tag_name :g

    attr_accessor :model, :clickable_element, :line_element, :x_element

    def initialize(model)
      self.model = model
      model.add_observer(:state) { render }
    end

    def create_element
      el = SVGElement.new(tag_name)
      self.line_element = create_line_element
      el.append(line_element)
      unless model.fixed?
        self.x_element = create_x_element
        self.clickable_element = create_clickable_element
        el.append(x_element).append(clickable_element)
      end
      el
    end

    def render
      element
      line_element[:stroke] = line_stroke
      if x_element
        x_element[:stroke] = x_stroke
      end
      self
    end

    on :click, '[cursor=pointer]' do |evt|
      model.state = case model.state
                    when nil
                      :present
                    when :present
                      :absent
                    end
    end

    on :selectstart, &:kill # don't select text on double or triple click!

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

    def line_stroke
      if model.present?
        model.fixed? ? :gray : :black
      end
    end

    def create_x_element
      el = SVGElement.new(:path)
      el['stroke-width'] = 0.05
      # Calculate the midpoint of the line:
      x = (model.dot1.col + model.dot2.col)/2
      y = (model.dot1.row + model.dot2.row)/2
      el[:d] =
        "M#{x-0.1} #{y-0.1}L#{x+0.1} #{y+0.1}" + # \
        "M#{x+0.1} #{y-0.1}L#{x-0.1} #{y+0.1}"   # /
    end

    def x_stroke
      model.absent? ? :red : nil
    end

  end
end
