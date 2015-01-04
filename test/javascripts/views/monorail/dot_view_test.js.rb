require 'views/monorail/dot_view'

module Monorail
  class DotViewTest < Minitest::Test
    attr_accessor *%i(parent coords view el)

    def setup
      self.parent = MonorailView.new
      self.coords = { cx: 10, cy: 20 }
      self.view = Monorail::DotView.new(parent, coords)
      self.el = view.element
    end

    test 'element is a SVG circle' do
      assert_equal :circle, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
    end

    test 'initialize' do
      assert_equal parent, view.parent
      assert_equal coords, view.coords
    end

    test 'render' do
      view.render
      assert_equal :gray, el[:fill]
      assert_equal '5', el[:r]
      assert_equal '10', el[:cx]
      assert_equal '20', el[:cy]
    end
  end
end

