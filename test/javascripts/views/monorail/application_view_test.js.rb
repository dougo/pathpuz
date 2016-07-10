require 'views/pathpuz/monorail/application_view'

module Monorail
  class ApplicationViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      $$.location.hash = ''
      Puzzle.reset!
      unless Element.id(:puzzle)
        Element.new.send(:id=, :puzzle).append_to(Document.body)
      end
      self.model = Application.new
      self.view = ApplicationView.new(model).render
      self.el = view.element
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render' do
      assert_equal :puzzle, el.id
      assert_equal 'Build a monorail loop that visits every dot.', el.find(:p).first.text
      assert_kind_of PuzzleView, view.puzzle
      assert_equal model.puzzle, view.puzzle.model
      assert_equal 1, el.find('svg').length
      assert_equal 1, el.find('div.autohint').length
      buttons = el.find(:button)
      assert_equal ['Previous puzzle', 'Hint', 'Next puzzle'], buttons.map(&:text)
      assert buttons.first.prop('disabled')
    end

    test 'next/prev buttons' do
      next_button.trigger(:click)
      model.router.update # TODO: shouldn't the hashchange event do this?
      assert_equal 1, model.puzzle.id
      assert_equal 1, view.element.find('svg').length, 'view element should be emptied'

      refute prev_button.prop('disabled')
      prev_button.trigger(:click); model.router.update
      assert_equal 0, model.puzzle.id
    end

    test 'render when the model changes' do
      puzzle_view = view.puzzle
      model.puzzle = Puzzle.find(1)
      refute_equal puzzle_view, view.puzzle
    end

    private

    def prev_button
      el.find('button:contains("Previous puzzle")')
    end

    def next_button
      el.find('button:contains("Next puzzle")')
    end
  end
end
