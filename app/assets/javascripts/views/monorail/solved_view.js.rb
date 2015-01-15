require 'vienna'

module Monorail
  class SolvedView < Vienna::View
    attr_accessor :model

    tag_name :g

    def initialize(model)
      self.model = model
      model.on(:solved) { render }
    end

    def create_element
      SVGElement.new(tag_name)
    end

    def render
      if model.solved?
        # Cover the grid with a transparent rectangle to catch/ignore all clicks.
        rect = SVGElement.new(:rect)
        rect[:x] = -1
        rect[:y] = -1
        rect[:width] = '100%'
        rect[:height] = '100%'
        rect[:fill] = :transparent
        element.append(rect)

        text = SVGElement.new(:text).attr(:class, :solved).text('Solved!')
        element.append(text)

        # Make the text width equal the viewport width:
        rect_bbox = `rect[0].getBBox()`
        text_bbox = `text[0].getBBox()`
        scale = `rect_bbox.width` / `text_bbox.width`

        # The origin of the text is at the baseline, i.e. the "current text position" is at y=0 and the top of
        # the bounding box is at -baseline. For simplification, move the current text position down to
        # y=baseline so that the origin is at the top of the bounding box.
        text[:y] = - `text_bbox.y`

        # Move the text origin to the left edge and halfway down from the top edge, minus half the text height:
        dx = -1
        dy = -1 + `rect_bbox.height`/2 - scale * `text_bbox.height`/2

        text[:transform] = "translate(#{dx} #{dy}) scale(#{scale})"
      end
      self
    end
  end
end
