require 'vienna'
require 'native'

module Monorail
  class SVGView < Vienna::View
    tag_name :svg

    attr_accessor :dots, :lines

    def initialize(parent)
      self.parent = parent
    end

    def create_element
      el = SVGElement.new(tag_name)
      el[:height] = 500
      el[:width] = 500
      # jQuery.attr downcases attribute names: http://bugs.jquery.com/ticket/11166
      # So we have to use raw setAttribute instead.
      `#{el}[0].setAttribute('viewBox', '-1 -1 3 3')`
      el.append_to parent.element
    end

    def puzzle
      parent.model
    end

    def render
      self.dots = puzzle.dots.flat_map do |row|
        row.map do |dot|
          Monorail::DotView.new(dot, self)
        end
      end

      self.lines = puzzle.lines.map do |line|
        Monorail::LineView.new(line, self)
      end

      dots.each &:render
      lines.each &:render
    end
  end
end
