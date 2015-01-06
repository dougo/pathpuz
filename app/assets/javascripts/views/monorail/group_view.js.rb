require 'vienna'

module Monorail
  class GroupView < Vienna::View
    tag_name :g

    def initialize(parent)
      self.parent = parent
    end

    def create_element
      el = SVGElement.new(tag_name)
      el[:transform] = 'translate(30 30) scale(90)'
      el.append_to parent.element
    end

    attr_accessor :dots, :lines

    def puzzle
      parent.parent.model
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
