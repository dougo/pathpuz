require 'views/monorail/line_view'

module Monorail
  class LineViewTest < Minitest::Test
    attr_accessor *%i(parent view el model)

    def setup
      self.model = Monorail::Line.new(dot1: Monorail::Dot.new(row: 0, col: 1),
                                      dot2: Monorail::Dot.new(row: 2, col: 3))
      self.parent = MonorailView.new
      self.view = Monorail::LineView.new(model, parent)
      self.el = view.element
    end

    test 'element is a transparent wide SVG line' do
      assert_equal :line, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal :transparent, el[:stroke]
      assert_equal '10', el['stroke-width']
      assert_equal '40', el[:x1]
      assert_equal '10', el[:y1]
      assert_equal '100', el[:x2]
      assert_equal '70', el[:y2]
    end

    test 'line_element is a strokeless narrow SVG line' do
      el = view.line_element
      assert_equal :line, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal '3', el['stroke-width']
      assert_equal :round, el['stroke-linecap']
      assert_equal '40', el[:x1]
      assert_equal '10', el[:y1]
      assert_equal '100', el[:x2]
      assert_equal '70', el[:y2]
    end

    test 'initialize' do
      assert_equal model, view.model
      assert_equal parent, view.parent
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

