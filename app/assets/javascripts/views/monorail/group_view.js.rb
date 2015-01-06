require 'vienna'

module Monorail
  class GroupView < Vienna::View
    tag_name :g

    def initialize(parent)
      self.parent = parent
    end

    def create_element
      el = SVGElement.new(tag_name)
      el[:transform] = 'translate(10 10) scale(30)'
      el.append_to parent.element
    end

    attr_accessor :dots, :lines

    def render
      dot_models = (0..1).map do |row|
        (0..1).map do |col|
          Monorail::Dot.new(row: row, col: col)
        end
      end
      
      line_models = [Monorail::Line.new(dot1: dot_models[0][0], dot2: dot_models[0][1]),
                     Monorail::Line.new(dot1: dot_models[0][0], dot2: dot_models[1][0]),
                     Monorail::Line.new(dot1: dot_models[0][1], dot2: dot_models[1][1]),
                     Monorail::Line.new(dot1: dot_models[1][0], dot2: dot_models[1][1])]

      self.dots = dot_models.flat_map do |row|
        row.map do |dot|
          Monorail::DotView.new(dot, self)
        end
      end

      self.lines = line_models.map do |line|
        Monorail::LineView.new(line, self)
      end

      dots.each &:render
      lines.each &:render
    end
  end
end
