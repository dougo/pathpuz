require 'views/pathpuz/monorail/application_view'

module Monorail
  class ApplicationViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      $global.location.hash = ''
      self.model = Application.new
      self.view = ApplicationView.new(model)
      view.render
      self.el = view.element
    end

    test 'initialize' do
      assert_equal model, view.model
      assert_kind_of Vienna::Router, view.router
    end

    test 'render' do
      assert_equal 'Build a monorail loop that visits every dot.', el.find(:p).first.text
      assert_kind_of PuzzleView, view.puzzle
      assert_equal model.puzzle, view.puzzle.model
      assert view.element.find('svg')
      buttons = el.find(:button)
      assert_equal 2, buttons.length
      assert_equal 'Hint', buttons.first.text
      assert_equal 'Next puzzle', buttons.last.text
    end

    test 'new puzzle on button click' do
      puzzle = model.puzzle
      next_button.trigger(:click)
      view.router.update # TODO: shouldn't the hashchange event do this?
      refute_equal puzzle, model.puzzle
      assert_equal 10, model.puzzle.lines.length
      assert_equal "##{model.puzzle.id}", $global.location.hash
    end

    test 'return to old puzzle on back button' do
      puzzle = model.puzzle
      next_button.trigger(:click)
      view.router.update
      # `history.back()` # TODO: why doesn't this work?
      $global.location.hash = ''
      view.router.update
      assert_equal puzzle, model.puzzle
    end

    test 'render when the model changes' do
      puzzle_view = view.puzzle
      model.puzzle = Puzzle.find(1)
      refute_equal puzzle_view, view.puzzle
    end

    test 'hint button completes a dot' do
      puzzle = model.puzzle = Puzzle.of_size(2)
      hint_button.trigger(:click)
      assert_equal 2, puzzle.dots.first.present_lines.length

      puzzle.lines.each { |l| l.state = :present }
      hint_button.trigger(:click) # does nothing, but test that it doesn't raise an error
    end

    test 'auto-hint checkbox' do
      autohint = el.find('div.autohint')
      assert_equal 1, autohint.length
      label = autohint.find('label')
      assert_equal 1, label.length
      assert_equal 'Auto-hint', label.text
      checkbox = label.find('input:checkbox')
      assert_equal 1, checkbox.length
    end

    test 'auto-hint behavior' do
      events = []
      puzzle = Puzzle.of_size(2)
      puzzle.on(:lines_changed) { |*args| events << args }
      model.puzzle = puzzle
      autohint = el.find('.autohint input:checkbox')
      autohint.prop(:checked, true)
      puzzle.trigger(:lines_changed) # TODO: this shouldn't be needed
      assert_equal [[], puzzle.dots.first.lines, [puzzle.lines[2]], [puzzle.lines[3]]], events
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
