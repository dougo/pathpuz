require 'vienna'

module Monorail
  class PuzzleView < Vienna::View
    tag_name :svg

    attr_accessor :model, :group

    def initialize(model)
      self.model = model
    end

    def create_element
      SVGElement.new(tag_name)
    end

    def render
      self.group = Monorail::GroupView.new(self)
      group.render
    end
  end
end
