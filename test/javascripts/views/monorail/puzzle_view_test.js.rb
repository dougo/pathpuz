require 'views/pathpuz/monorail/puzzle_view'

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
      assert_equal 'Build a monorail loop that visits every dot.', el.find(:p).first.text
      assert_kind_of SVGView, view.svg
      assert_equal model, view.svg.model
      assert view.element.find('svg')
      assert_equal 'Next puzzle', el.find(:button).text
    end

    test 'new puzzle on button click' do
      el.find(:button).trigger(:click)
      refute_equal model, view.model
      assert_equal 10, view.model.lines.length
    end

    test 'render when the model changes' do
      svg = view.svg
      view.model = Puzzle.new
      refute_equal svg, view.svg
    end
  end
end
