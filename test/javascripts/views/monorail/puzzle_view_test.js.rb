require 'views/pathpuz/monorail/puzzle_view'

module Monorail
  class PuzzleViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      $global.location.hash = ''
      self.model = Puzzle.find(0)
      self.view = PuzzleView.new(model)
      view.render
      self.el = view.element
    end

    test 'initialize' do
      assert_equal model, view.model
      assert_kind_of Vienna::Router, view.router
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
      view.router.update # TODO: shouldn't the hashchange event do this?
      refute_equal model, view.model
      assert_equal 10, view.model.lines.length
      assert_equal "##{view.model.id}", $global.location.hash
    end

    test 'return to old puzzle on back button' do
      el.find(:button).trigger(:click)
      view.router.update
      # `history.back()` # TODO: why doesn't this work?
      $global.location.hash = ''
      view.router.update
      assert_equal model, view.model
    end

    test 'render when the model changes' do
      svg = view.svg
      view.model = Puzzle.find(1)
      refute_equal svg, view.svg
    end
  end
end
