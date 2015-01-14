require 'views/monorail/svg_view'

module Monorail
  class SVGViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      self.model = Puzzle.new
      self.view = SVGView.new(model)
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
      assert_equal '500', el[:height]
      assert_equal '500', el[:width]
      assert_equal '-1 -1 3 3', `#{el}[0].getAttribute('viewBox')`
    end

    test 'has one DotView per Dot in puzzle' do
      dots = model.dots
      dot_views = view.dots
      assert_equal dots.length * dots.first.length, dot_views.length
      dot_views.each do |dot_view|
        assert_kind_of DotView, dot_view
        dot = dot_view.model
        assert_equal dots[dot.row][dot.col], dot
        # TODO: is there a better way to test that dot_view.element was added and dot_view was rendered?
        assert_equal 1, view.element.find("circle[cx=#{dot.col}][cy=#{dot.row}]").length
      end
    end

    test 'has one LineView per Line in puzzle' do
      lines = model.lines
      line_views = view.lines
      lines.zip(line_views).each do |line, line_view|
        assert_kind_of LineView, line_view
        assert_equal line, line_view.model
        # TODO: is there a better way to test that line_view.element and line_view.line_element were added and line_view was rendered?
        assert_equal 2, view.element.find("line[x1=#{line.dot1.col}][y1=#{line.dot1.row}][x2=#{line.dot2.col}][y2=#{line.dot2.row}]").length
      end
    end
  end
end
