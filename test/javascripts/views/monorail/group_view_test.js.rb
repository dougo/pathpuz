require 'views/monorail/group_view'

module Monorail
  class GroupViewTest < Minitest::Test
    attr_accessor :parent, :view, :el

    def setup
      self.parent = PuzzleView.new
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

    test 'has four DotViews' do
      dots = view.dots
      assert_equal 4, dots.length
      dots.each do |dot|
        assert_kind_of Monorail::DotView, dot
        assert_equal view, dot.parent
      end
    end

    test 'dots form a square' do
      dots = view.dots
      assert_equal 2, dots.select { |dot| dot.model[:row] == 0 }.length
      assert_equal 2, dots.select { |dot| dot.model[:row] == 1 }.length
      assert_equal 2, dots.select { |dot| dot.model[:col] == 0 }.length
      assert_equal 2, dots.select { |dot| dot.model[:col] == 1 }.length
    end

    test 'has four LineViews' do
      lines = view.lines
      assert_equal 4, lines.length
      lines.each do |line|
        assert_kind_of Monorail::LineView, line
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
