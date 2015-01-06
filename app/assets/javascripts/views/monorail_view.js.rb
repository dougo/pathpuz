require 'vienna'

class MonorailView < Vienna::View
  tag_name :svg

  def create_element
    SVGElement.new(tag_name)
  end

  attr_accessor :dots, :lines

  def render
    self.dots = []
    (0..1).each do |row|
      (0..1).each do |col|
        dots << Monorail::DotView.new(Monorail::Dot.new(row: row, col: col), self)
      end
    end
    dots.each &:render

    self.lines = []
    lines << Monorail::LineView.new(self, x1: 10, y1: 10, x2: 40, y2: 10)
    lines << Monorail::LineView.new(self, x1: 10, y1: 10, x2: 10, y2: 40)
    lines << Monorail::LineView.new(self, x1: 40, y1: 10, x2: 40, y2: 40)
    lines << Monorail::LineView.new(self, x1: 10, y1: 40, x2: 40, y2: 40)
    lines.each &:render
  end
end
