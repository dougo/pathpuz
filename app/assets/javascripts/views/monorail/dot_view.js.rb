require 'vienna'

module Monorail
  class DotView < Vienna::View
    tag_name :circle

    def create_element
      el = SVGElement.new(tag_name)
      el.append_to parent.element
    end

    attr_accessor :coords

    def initialize(parent, coords)
      self.parent = parent
      self.coords = coords
    end

    def render
      element[:fill] = :gray
      element[:r] = 5
      element[:cx] = coords[:cx]
      element[:cy] = coords[:cy]
    end
  end
end
