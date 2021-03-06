require 'vienna'
require 'native'

module Monorail
  class PuzzleView < Vienna::View
    tag_name :svg

    attr_accessor :model, :dots, :lines

    def initialize(model)
      self.model = model
      model.on(:solved) { set_class }
      model.on(:undone) { set_class }
    end

    def create_element
      el = SVGElement.new(tag_name)
      viewBox = "-1 -1 #{model.width + 1} #{model.height + 1}"
      # jQuery.attr downcases attribute names: http://bugs.jquery.com/ticket/11166
      # So we have to use raw setAttribute instead.
      `#{el}[0].setAttribute('viewBox', #{viewBox})`
      el
    end

    def render
      self.dots = model.dots.map { |dot| DotView.new(dot) }
      self.lines = model.lines.map { |line| LineView.new(line) }

      element.empty
      dots.each { |dot| element.append(dot.render.element) }

      # Render fixed lines first, so that they have lower z-index and appear underneath user-drawn lines.
      fixed, unfixed = lines.partition { |l| l.model.fixed? }
      [fixed, unfixed].each do |lines|
        lines.each { |line| element.append(line.render.element) }
      end

      set_class

      self
    end

    on :selectstart, &:kill # don't select text on double or triple click!

    private

    def set_class
      if model.solved?
        element.add_class(:solved)
      else
        element.remove_class(:solved)
      end
    end
  end
end
