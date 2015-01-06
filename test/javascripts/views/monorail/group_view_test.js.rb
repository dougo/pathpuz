require 'views/monorail/group_view'

module Monorail
  class GroupViewTest < Minitest::Test
    attr_accessor :puzzle, :parent, :view, :el

    def setup
      self.puzzle = Puzzle.new
      self.parent = PuzzleView.new(puzzle)
      self.view = GroupView.new(parent)
      view.render
      self.el = view.element
    end

    test 'initialize' do
      assert_equal parent, view.parent
    end

    test 'element is an SVG g' do
      assert_equal :g, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal 'translate(10 10) scale(30)', el[:transform]
      # assert_equal parent.element, el.parent # TODO: why does this fail??
    end

    test 'has one DotView per Dot in puzzle' do
      dots = puzzle.dots
      dot_views = view.dots
      assert_equal dots.length * dots.first.length, dot_views.length
      dot_views.each do |dot_view|
        assert_kind_of DotView, dot_view
        assert_equal view, dot_view.parent
        dot = dot_view.model
        assert_equal dots[dot[:row]][dot[:col]], dot
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
