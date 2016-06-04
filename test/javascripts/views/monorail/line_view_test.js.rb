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

    test 'element is an SVG g with two lines' do
      assert_equal :g, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal 2, el.find('line').length
    end

    test 'clickable_element is a transparent wide SVG line' do
      el = view.clickable_element
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
      assert_nil el[:stroke]
      assert_equal '0.1', el['stroke-width']
      assert_equal :round, el['stroke-linecap']
      assert_equal '1', el[:x1]
      assert_equal '0', el[:y1]
      assert_equal '3', el[:x2]
      assert_equal '2', el[:y2]
    end

    test 'fixed line has no clickable element' do
      model.state = :fixed
      view = LineView.new(model)
      el = view.element
      assert_equal 1, el.find('line').length
      assert_nil view.clickable_element
    end

    test 'render gets line_element stroke from model' do
      el = view.line_element
      assert_equal view, view.render
      refute el.has_attribute? :stroke

      model.state = :present
      view.render
      assert_equal :black, el[:stroke]

      model.state = :fixed
      view.render
      assert_equal :gray, el[:stroke]
    end

    test 'update the model when clickable element is clicked' do
      el = view.clickable_element
      el.trigger(:click)
      assert model.present?

      el.trigger(:click)
      refute model.present?
    end

    test 'render when the model presence changes' do
      model.state = :present
      assert_equal :black, view.line_element[:stroke]
      
      model.state = nil
      refute view.line_element.has_attribute? :stroke
    end
  end
end

