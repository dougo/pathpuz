require 'views/pathpuz/monorail/line_view'

module Monorail
  class LineViewTest < Minitest::Test
    attr_accessor *%i(view el model)

    def setup
      self.model = Line.new(dot1: Dot.new(row: 0, col: 1),
                            dot2: Dot.new(row: 2, col: 3))
      self.view = LineView.new(model)
      self.el = view.element
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'element is an SVG g with two lines and a path' do
      assert_equal :g, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal 2, el.find('line').length
      assert_equal 1, el.find('path').length
    end

    test 'clickable_element is a transparent wide SVG line' do
      el = view.clickable_element
      assert_equal :line, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal :transparent, el[:stroke]
      assert_equal 0.3, el['stroke-width'].to_f
      assert_equal :pointer, el[:cursor]
      assert_equal 1+0.15, el[:x1].to_f
      assert_equal 0+0.15, el[:y1].to_f
      assert_equal 3-0.15, el[:x2].to_f
      assert_equal 2-0.15, el[:y2].to_f
    end

    test 'clickable_element is straight when horizontal' do
      model.dot2.row = 0
      el = view.create_clickable_element
      assert_equal 1+0.15, el[:x1].to_f
      assert_equal 0,      el[:y1].to_f
      assert_equal 3-0.15, el[:x2].to_f
      assert_equal 0,      el[:y2].to_f
    end

    test 'clickable_element is straight when vertical' do
      model.dot2.col = 1
      el = view.create_clickable_element
      assert_equal 1,      el[:x1].to_f
      assert_equal 0+0.15, el[:y1].to_f
      assert_equal 1,      el[:x2].to_f
      assert_equal 2-0.15, el[:y2].to_f
    end

    test 'line_element is a strokeless narrow SVG line' do
      el = view.line_element
      assert_equal :line, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_nil el[:stroke]
      assert_equal '0.1', el['stroke-width']
      assert_equal :round, el['stroke-linecap']
      assert_equal :none, el['pointer-events']
      assert_equal '1', el[:x1]
      assert_equal '0', el[:y1]
      assert_equal '3', el[:x2]
      assert_equal '2', el[:y2]
    end

    test 'x_element is a strokeless SVG path' do
      el = view.x_element
      assert_equal :path, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_nil el[:stroke]
      assert_equal '0.05', el['stroke-width']
      # Midpoint of the line is (x1+x2)/2,(y1+y2)/2 = 2,1.
      assert_equal 'M1.9 0.9L2.1 1.1M2.1 0.9L1.9 1.1', el[:d]
    end

    test 'fixed line has no clickable element or X element' do
      model.state = :fixed
      view = LineView.new(model)
      el = view.element
      assert_equal 1, el.find('line').length
      assert_nil view.clickable_element
      assert_empty el.find('path')
      assert_nil view.x_element
    end

    test 'render gets class and line_element stroke from model' do
      el = view.line_element
      assert_equal view, view.render
      refute el.has_class? :present
      refute el.has_attribute? :stroke

      model.state = :present
      view.render
      assert el.has_class? :present
      assert_equal :black, el[:stroke]

      model.state = :absent
      view.render
      refute el.has_class? :present
      refute el.has_attribute? :stroke

      model.state = :fixed
      view.render
      assert el.has_class? :present
      assert_equal :gray, el[:stroke]
    end

    test 'render gets x_element stroke from model' do
      el = view.x_element
      view.render
      refute el.has_attribute? :stroke

      model.state = :absent
      view.render
      assert_equal :red, el[:stroke]
    end

    test 'update the model when clickable element is clicked' do
      el = view.clickable_element
      event = false
      model.on(:next_state) { event = true }
      el.trigger(:click)
      assert model.present?
      assert event
    end

    test 'render when the model presence changes' do
      model.state = :present
      assert_equal :black, view.line_element[:stroke]
      
      model.state = nil
      refute view.line_element.has_attribute? :stroke
    end

    test 'double click does not select text' do
      el = (PuzzleView.new(Puzzle.of_size(2)).render).element
      # I don't know how to actually cause text to be selected, so let's just test that the selectstart event is
      # not propagated:
      selection = nil
      el.on(:selectstart) { selection = true }
      el.find('line[cursor=pointer]').first.trigger(:selectstart)
      assert_nil selection
    end
  end
end
