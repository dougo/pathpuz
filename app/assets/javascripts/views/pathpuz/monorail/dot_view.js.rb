require 'vienna'

module Monorail
  class DotView < Vienna::View
    tag_name :circle

    def create_element
      SVGElement.new(tag_name)
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
  end
end
