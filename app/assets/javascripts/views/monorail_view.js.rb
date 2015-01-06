require 'vienna'

class MonorailView < Vienna::View
  tag_name :svg

  attr_accessor :group

  def create_element
    SVGElement.new(tag_name)
  end

  def render
    self.group = Monorail::GroupView.new(self)
    group.render
  end
end
