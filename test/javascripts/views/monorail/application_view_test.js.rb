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
      model.router.update # TODO: shouldn't the hashchange event do this?
      refute_equal puzzle, model.puzzle
    end

    test 'render when the model changes' do
      puzzle_view = view.puzzle
      model.puzzle = Puzzle.find(1)
      refute_equal puzzle_view, view.puzzle
    end

    test 'hint button changes lines' do
      puzzle = model.puzzle = Puzzle.of_size(2)
      event = false
      puzzle.on(:lines_changed) { event = true }
      hint_button.trigger(:click)
      assert event
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

    test 'auto-hint checkbox changes the model' do
      autohint_on!
      assert model.autohint
      autohint_off!
      refute model.autohint
    end

    test 'auto-hint checkbox reflects the model state' do
      refute autohint_checkbox.is(':checked')
      view = ApplicationView.new(Application.new(autohint: true)).render
      self.el = view.element
      assert autohint_checkbox.is(':checked')
    end

    test 'auto-hint checkbox is updated when the model changes' do
      model.autohint = true
      assert autohint_checkbox.is(':checked')
      model.autohint = false
      refute autohint_checkbox.is(':checked')
    end

    private

    def autohint_checkbox
      el.find('.autohint input:checkbox')
    end

    def autohint_on!
      autohint_checkbox.prop(:checked, true).trigger(:change)
    end

    def autohint_off!
      autohint_checkbox.prop(:checked, false).trigger(:change)
    end

    def hint_button
      el.find('button:contains("Hint")')
    end

    def next_button
      el.find('button:contains("Next puzzle")')
    end
  end
end
