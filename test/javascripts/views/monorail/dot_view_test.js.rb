module Monorail
  class DotViewTest < ViewTest
    self.view_class = DotView

    def setup
      @model = Dot.new(row: 1, col: 2)
    end

    test 'element is a clickable SVG circle' do
      assert_equal :circle, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
      assert_equal :pointer, el[:cursor]
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render' do
      assert_equal :gray, el[:fill]
      assert_equal '0.15', el[:r]
      assert_equal '2', el[:cx]
      assert_equal '1', el[:cy]
    end

    test 'click completes the dot' do
      model.lines << Line.new << Line.new
      completed = false
      model.on(:completed) { completed = true }
      el.trigger(:click)
      assert completed
    end
  end
end

