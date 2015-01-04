require 'views/monorail/line_view'

module Monorail
  class LineViewTest < Minitest::Test
    attr_accessor *%i(parent coords view el)

    def setup
      self.parent = MonorailView.new
      self.coords = { x1: 10, y1: 20, x2: 30, y2: 40 }
      self.view = Monorail::LineView.new(parent, coords)
      self.el = view.element
    end

    test 'element is a SVG line' do
      assert_equal :line, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
    end

    test 'initialize' do
      assert_equal parent, view.parent
      assert_equal coords, view.coords
    end

    test 'render' do
      view.render
      assert_equal :transparent, el[:stroke]
      assert_equal '3', el['stroke-width']
      assert_equal '10', el[:x1]
      assert_equal '20', el[:y1]
      assert_equal '30', el[:x2]
      assert_equal '40', el[:y2]
    end

    test 'can be clicked' do
      view.render
      assert_equal :transparent, el[:stroke]
      el.trigger(:click)
      assert_equal :black, el[:stroke]
      el.trigger(:click)
      assert_equal :transparent, el[:stroke]
    end
  end
end

