require 'vienna'

module Monorail
  class SVGView < Vienna::View
    tag_name :svg

    attr_accessor :group

    def initialize(parent)
      self.parent = parent
    end

    def create_element
      el = SVGElement.new(tag_name)
      el.append_to parent.element
    end

    def render
      self.group = GroupView.new(self)
      group.render
    end
  end
end
