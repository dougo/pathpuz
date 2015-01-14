require 'views/monorail/dot_view'

module Monorail
  class DotViewTest < Minitest::Test
    attr_accessor *%i(model parent view el)

    def setup
      self.model = Dot.new(row: 1, col: 2)
      self.parent = SVGView.new(PuzzleView.new)
      self.view = DotView.new(model, parent)
      self.el = view.element
    end

    test 'element is a SVG circle' do
      assert_equal :circle, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
    end

    test 'initialize' do
      assert_equal model, view.model
      assert_equal parent, view.parent
    end

    test 'render' do
      view.render
      assert_equal :gray, el[:fill]
      assert_equal '0.15', el[:r]
      assert_equal '2', el[:cx]
      assert_equal '1', el[:cy]
    end
  end
end

