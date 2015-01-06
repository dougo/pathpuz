require 'views/monorail/puzzle_view'

module Monorail
  class PuzzleViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      self.model = Puzzle.new
      self.view = PuzzleView.new(model)
      view.render
      self.el = view.element
    end

    test 'initialize' do
      assert_equal model, view.model
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
