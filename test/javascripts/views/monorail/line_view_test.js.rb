require 'views/monorail/line_view'

module Monorail
  class LineViewTest < Minitest::Test
    attr_accessor *%i(view el model)

    def setup
      self.model = Line.new(dot1: Dot.new(row: 0, col: 1),
                            dot2: Dot.new(row: 2, col: 3))
      self.view = LineView.new(model)
      self.el = view.element
    end

    test 'element is a transparent wide SVG line' do
      assert_equal :line, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal :transparent, el[:stroke]
      assert_equal '0.3', el['stroke-width']
      assert_equal :pointer, el[:cursor]
      assert_equal '1', el[:x1]
      assert_equal '0', el[:y1]
      assert_equal '3', el[:x2]
      assert_equal '2', el[:y2]
    end

    test 'line_element is a strokeless narrow SVG line' do
      el = view.line_element
      assert_equal :line, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal '0.1', el['stroke-width']
      assert_equal :round, el['stroke-linecap']
      assert_equal '1', el[:x1]
      assert_equal '0', el[:y1]
      assert_equal '3', el[:x2]
      assert_equal '2', el[:y2]
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render gets line_element stroke from model' do
      el = view.line_element
      assert_equal view, view.render
      refute el.has_attribute? :stroke

      model.present? = true
      view.render
      assert_equal :black, el[:stroke]
    end

    test 'update the model when clicked' do
      el.trigger(:click)
      assert_equal true, model.present?

      el.trigger(:click)
      assert_nil model.present?
    end

    test 'render when the model presence changes' do
      model.present? = true
      assert_equal :black, view.line_element[:stroke]
      
      model.present? = false
      refute view.line_element.has_attribute? :stroke
    end
  end
end

