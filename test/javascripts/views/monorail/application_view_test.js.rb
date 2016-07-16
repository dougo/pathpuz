module Monorail
  class ApplicationViewTest < ViewTest
    self.model_class = Application
    self.view_class = ApplicationView

    def setup
      $$.location.hash = ''
      Puzzle.reset!
      unless Element.id(:puzzle)
        Element.new.send(:id=, :puzzle).append_to(Document.body)
      end
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render' do
      assert_equal :puzzle, el.id
      assert_equal 'Build a monorail loop that visits every dot.', el.find(:p).first.text
      assert_equal 1, el.find('svg').length
      assert_equal 1, el.find('div.autohint').length
      buttons = el.find(:button)
      assert_equal ['Previous puzzle', 'Undo', 'Hint', 'Next puzzle'], buttons.map(&:text)
      assert_equal 'prev', buttons.first.class_name
      assert_equal 'next', buttons.last.class_name
    end

    test 'next/prev buttons' do
      prev = el.find('.prev')
      assert prev.prop('disabled')
      el.find('.next').trigger(:click); model.router.update
      assert_equal 1, model.puzzle.id
      assert_equal 1, view.element.find('svg').length, 'view element should be emptied'

      prev = el.find('.prev')
      refute prev.prop('disabled')
      prev.trigger(:click); model.router.update
      assert_equal 0, model.puzzle.id
    end

    test 'render when the model changes' do
      svg = el.find('svg')
      model.puzzle = Puzzle.find(1)
      refute_equal svg, el.find('svg')
    end
  end
end
