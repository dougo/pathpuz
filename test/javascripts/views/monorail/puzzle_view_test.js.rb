require 'views/monorail/puzzle_view'

module Monorail
  class PuzzleViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      self.model = Puzzle.new
      self.view = PuzzleView.new(model)
      view.render
      self.el = view.element
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render' do
      assert_equal 'Build a monorail loop that visits every dot.', el.text
      assert_kind_of SVGView, view.svg
      assert_equal view, view.svg.parent
    end
  end
end
