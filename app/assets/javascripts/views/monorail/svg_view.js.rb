require 'vienna'
require 'native'

module Monorail
  class SVGView < Vienna::View
    tag_name :svg

    attr_accessor :model, :dots, :lines

    def initialize(model)
      self.model = model
    end

    def create_element
      el = SVGElement.new(tag_name)
      el[:height] = 500
      el[:width] = 500
      # jQuery.attr downcases attribute names: http://bugs.jquery.com/ticket/11166
      # So we have to use raw setAttribute instead.
      `#{el}[0].setAttribute('viewBox', '-1 -1 3 3')`
      el
    end

    def render
      self.dots = model.dots.flat_map do |row|
        row.map do |dot|
          Monorail::DotView.new(dot)
        end
      end

      self.lines = model.lines.map do |line|
        Monorail::LineView.new(line)
      end

      dots.each { |dot| dot.render; element.append(dot.element) }
      lines.each do |line|
        line.render
        element.append(line.line_element)
        # Add this second so that the click target will be on top of the stroke.
        element.append(line.element)
      end
    end
  end
end
