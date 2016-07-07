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
      buttons = el.find(:button)
      assert_equal 2, buttons.length
      assert_equal 'Hint', buttons.first.text
      assert_equal 'Next puzzle', buttons.last.text
    end

    test 'new puzzle on button click' do
      next_button.trigger(:click)
      view.router.update # TODO: shouldn't the hashchange event do this?
      refute_equal model, view.model
      assert_equal 10, view.model.lines.length
      assert_equal "##{view.model.id}", $global.location.hash
    end

    test 'return to old puzzle on back button' do
      next_button.trigger(:click)
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

    test 'hint button completes a dot' do
      hint_button.trigger(:click)
      assert_equal 2, model.dots.first.present_lines.length

      model.lines.each { |l| l.state = :present }
      hint_button.trigger(:click) # does nothing, but test that it doesn't raise an error
    end

    private

    def hint_button
      el.find('button:contains("Hint")')
    end

    def next_button
      el.find('button:contains("Next puzzle")')
    end
  end
end
