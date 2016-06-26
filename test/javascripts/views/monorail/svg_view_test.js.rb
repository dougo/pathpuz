require 'views/pathpuz/monorail/svg_view'

module Monorail
  class SVGViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      self.model = Puzzle.of_size(2)
      self.view = SVGView.new(model)
      self.el = view.element
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'element is svg' do
      assert_equal :svg, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal SVGElement::NS, el[:xmlns]
      assert_equal '-1 -1 3 3', `#{el}[0].getAttribute('viewBox')`
    end

    test 'viewBox depends on puzzle size' do
      model = Puzzle.of_size(3)
      el = SVGView.new(model).element
      assert_equal '-1 -1 4 4', `#{el}[0].getAttribute('viewBox')`

      model.dot_rows << [Dot.new(row: 3, col: 1)]
      el = SVGView.new(model).element
      assert_equal '-1 -1 4 5', `#{el}[0].getAttribute('viewBox')`
    end

    test 'render' do
      assert_equal view, view.render
      assert_kind_of SolvedView, view.solved
      assert_equal model, view.solved.model
      assert view.element.find('.solved')
    end

    test 'has one DotView per Dot in puzzle' do
      view.render
      dot_views = view.dots
      assert_equal model.dots.length, dot_views.length
      dot_views.each do |dot_view|
        assert_kind_of DotView, dot_view
        dot = dot_view.model
        assert_equal model.dot(dot.row, dot.col), dot
      end
      assert_equal dot_views.length, el.find('circle').length
    end

    test 'has one LineView per Line in puzzle' do
      view.render
      lines = model.lines
      line_views = view.lines
      lines.zip(line_views).each do |line, line_view|
        assert_kind_of LineView, line_view
        assert_equal line, line_view.model
      end
      assert_equal lines.length, el.find('line[cursor=pointer]').length
    end

    test 'renders fixed lines first so that they have lower z-index' do
      model.lines.last.state = :fixed
      view.render
      assert_equal 'gray', view.element.find(:line).first[:stroke]
    end
  end
end
