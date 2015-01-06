require 'vienna'

module Monorail
  class DotView < Vienna::View
    tag_name :circle

    def create_element
      el = SVGElement.new(tag_name)
      el.append_to parent.element
    end

    attr_accessor :model

    def initialize(model, parent)
      self.model = model
      self.parent = parent
    end

    def render
      element[:fill] = :gray
      element[:r] = 0.15
      element[:cx] = model.col
      element[:cy] = model.row
    end
  end
end
