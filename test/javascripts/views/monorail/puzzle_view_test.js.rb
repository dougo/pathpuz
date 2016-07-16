module Monorail
  class PuzzleViewTest < ViewTest
    self.view_class = PuzzleView

    def setup
      @model = Puzzle.of_size(2)
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
      @model = Puzzle.of_size(3)
      assert_equal '-1 -1 4 4', `#{el}[0].getAttribute('viewBox')`

      json = Puzzle.json_for_size(3)
      json[:lines] << { dot1: { row: 2, col: 1 }, dot2: { row: 3, col: 1 } }
      model = Puzzle.new(json)
      el = PuzzleView.new(model).element
      assert_equal '-1 -1 4 5', `#{el}[0].getAttribute('viewBox')`
    end

    test 'render' do
      assert_kind_of SolvedView, view.solved
      assert_equal model, view.solved.model
      assert el.find('.solved')
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
      assert_equal 'gray', el.find(:line).first[:stroke]
    end

    test 'render a solved model' do
      model.lines.each { |line| line.state = :present }
      assert el.has_class? :solved
      assert_equal 1, el.find('rect[fill="transparent"]').length
    end

    test 're-render when solved' do
      refute el.has_class? :solved
      model.lines.each { |line| line.state = :present }
      model.trigger(:solved)
      assert el.has_class? :solved
      assert_equal 1, el.find('rect[fill="transparent"]').length
    end

    # TODO: re-render when undone after solving? or disallow undo after solving?
  end
end
