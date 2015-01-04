require 'views/monorail/line_view'

module Monorail
  class LineViewTest < Minitest::Test
    attr_accessor *%i(parent coords view el model)

    def setup
      self.parent = MonorailView.new
      self.coords = { x1: 10, y1: 20, x2: 30, y2: 40 }
      self.view = Monorail::LineView.new(parent, coords)
      self.el = view.element
      self.model = view.model
    end

    test 'element is a transparent wide SVG line' do
      assert_equal :line, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal :transparent, el[:stroke]
      assert_equal '10', el['stroke-width']
      assert_equal '10', el[:x1]
      assert_equal '20', el[:y1]
      assert_equal '30', el[:x2]
      assert_equal '40', el[:y2]
    end

    test 'line_element is a strokeless narrow SVG line' do
      el = view.line_element
      assert_equal :line, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal '3', el['stroke-width']
      assert_equal :round, el['stroke-linecap']
      assert_equal '10', el[:x1]
      assert_equal '20', el[:y1]
      assert_equal '30', el[:x2]
      assert_equal '40', el[:y2]
    end

    test 'initialize' do
      assert_kind_of Line, model
      assert_equal parent, view.parent
      assert_equal coords, view.coords
    end

    test 'render gets line_element stroke from model' do
      el = view.line_element
      view.render
      refute el.has_attribute? :stroke

      model.present? = true
      view.render
      assert_equal :black, el[:stroke]
    end

    test 'can be clicked' do
      el.trigger(:click)
      assert_equal true, model.present?
      assert_equal :black, view.line_element[:stroke]
      el.trigger(:click)
      assert_nil model.present?
      refute view.line_element.has_attribute? :stroke
    end
  end
end

