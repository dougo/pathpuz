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

    test 'has four LineViews' do
      lines = view.lines
      assert_equal 4, lines.length
      lines.each do |line|
        assert_kind_of LineView, line
        assert_equal view, line.parent
      end
    end

    test 'lines form a square' do
      lines = view.lines
      assert_equal 2, lines.select { |line| line.model.dot1[:row] == line.model.dot2[:row] }.length
      assert_equal 2, lines.select { |line| line.model.dot1[:col] == line.model.dot2[:col] }.length
      assert_equal 2, lines.select { |line| line.model.dot1[:row] == 0 && line.model.dot1[:col] == 0 }.length
      assert_equal 2, lines.select { |line| line.model.dot2[:row] == 1 && line.model.dot2[:col] == 1 }.length
    end
  end
end
