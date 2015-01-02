require 'views/monorail/line_view'

module Monorail
  class LineViewTest < Minitest::Test
    attr_accessor *%i(parent coords view)

    def setup
      self.parent = MonorailView.new
      self.coords = { x1: 10, y1: 20, x2: 30, y2: 40 }
      self.view = Monorail::LineView.new(parent, coords)
    end

    test 'initialize' do
      assert_equal parent, view.parent
      assert_equal coords, view.coords
    end

    test 'render' do
      view.render
      line = view.element
      assert_equal :line, line.tag_name
      assert_equal :transparent, line[:stroke]
      assert_equal '3', line['stroke-width']
      assert_equal '10', line[:x1]
      assert_equal '20', line[:y1]
      assert_equal '30', line[:x2]
      assert_equal '40', line[:y2]
    end

    test 'can be clicked' do
      view.render
      line = view.element
      assert_equal :transparent, line[:stroke]
      line.trigger(:click)
      assert_equal :black, line[:stroke]
      line.trigger(:click)
      assert_equal :transparent, line[:stroke]
    end
  end
end

