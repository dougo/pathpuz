require 'views/monorail/svg_view'

module Monorail
  class SVGViewTest < Minitest::Test
    attr_accessor :parent, :view, :el

    def setup
      self.parent = PuzzleView.new(Puzzle.new)
      self.view = SVGView.new(parent)
      view.render
      self.el = view.element
    end

    test 'initialize' do
      assert_equal parent, view.parent
    end

    test 'element is svg' do
      assert_equal :svg, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal SVGElement::NS, el[:xmlns]
    end

    test 'render' do
      assert_kind_of GroupView, view.group
      assert_equal view, view.group.parent
    end
  end
end
