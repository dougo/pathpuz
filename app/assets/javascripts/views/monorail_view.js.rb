require 'vienna'

class MonorailView < Vienna::View
  tag_name :svg

  def create_element
    SVGElement.new(tag_name)
  end

  attr_accessor :dots, :lines

  def render
    self.dots = []
    dots << Monorail::DotView.new(self, cx: 10, cy: 10)
    dots << Monorail::DotView.new(self, cx: 40, cy: 10)
    dots << Monorail::DotView.new(self, cx: 10, cy: 40)
    dots << Monorail::DotView.new(self, cx: 40, cy: 40)
    dots.each &:render

    self.lines = []
    lines << Monorail::LineView.new(self, x1: 10, y1: 10, x2: 40, y2: 10)
    lines << Monorail::LineView.new(self, x1: 10, y1: 10, x2: 10, y2: 40)
    lines << Monorail::LineView.new(self, x1: 40, y1: 10, x2: 40, y2: 40)
    lines << Monorail::LineView.new(self, x1: 10, y1: 40, x2: 40, y2: 40)
    lines.each &:render
  end
end
