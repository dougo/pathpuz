require 'vienna'

module Monorail
  class DotView < Vienna::View
    tag_name :circle

    def create_element
      el = SVGElement.new(tag_name)
      el[:cursor] = :pointer
    end

    attr_accessor :model

    def initialize(model)
      self.model = model
    end

    def render
      element[:fill] = :gray
      element[:r] = 0.15
      element[:cx] = model.col
      element[:cy] = model.row
      self
    end

    on(:click) { model.complete! }
  end
end
