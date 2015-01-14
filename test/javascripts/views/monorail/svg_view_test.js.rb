require 'views/monorail/svg_view'

module Monorail
  class SVGViewTest < Minitest::Test
    attr_accessor :puzzle, :parent, :view, :el

    def setup
      self.puzzle = Puzzle.new
      self.parent = PuzzleView.new(puzzle)
      self.view = SVGView.new(parent)
      view.render
      self.el = view.element
    end

    test 'initialize' do
      assert_equal parent, view.parent
      assert_equal puzzle, view.puzzle
    end

    test 'element is svg' do
      assert_equal :svg, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal SVGElement::NS, el[:xmlns]
      assert_equal '500', el[:height]
      assert_equal '500', el[:width]
      assert_equal '-1 -1 3 3', `#{el}[0].getAttribute('viewBox')`
    end

    test 'has one DotView per Dot in puzzle' do
      dots = puzzle.dots
      dot_views = view.dots
      assert_equal dots.length * dots.first.length, dot_views.length
      dot_views.each do |dot_view|
        assert_kind_of DotView, dot_view
        assert_equal view, dot_view.parent
        dot = dot_view.model
        assert_equal dots[dot.row][dot.col], dot
      end
    end

    test 'has one LineView per Line in puzzle' do
      lines = puzzle.lines
      line_views = view.lines
      lines.zip(line_views).each do |line, line_view|
        assert_kind_of LineView, line_view
        assert_equal view, line_view.parent
        assert_equal line, line_view.model
      end
    end
  end
end
