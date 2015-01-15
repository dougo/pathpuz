require 'vienna'
require 'native'

module Monorail
  class SVGView < Vienna::View
    tag_name :svg

    attr_accessor :model, :dots, :lines, :solved

    def initialize(model)
      self.model = model
    end

    def create_element
      el = SVGElement.new(tag_name)
      el[:height] = 500
      el[:width] = 500
      viewBox = "-1 -1 #{model.width + 1} #{model.height + 1}"
      # jQuery.attr downcases attribute names: http://bugs.jquery.com/ticket/11166
      # So we have to use raw setAttribute instead.
      `#{el}[0].setAttribute('viewBox', #{viewBox})`
      el
    end

    def render
      self.dots = model.dots.map { |dot| DotView.new(dot) }
      self.lines = model.lines.map { |line| LineView.new(line) }
      self.solved = SolvedView.new(model)

      element.empty
      dots.each { |dot| element.append(dot.render.element) }
      lines.each { |line| element.append(line.render.element) }
      element.append(solved.render.element)

      self
    end
  end
end
