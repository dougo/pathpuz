module Monorail
  class HintButtonViewTest < ViewTest
    self.model_class = Application
    self.view_class = HintButtonView

    def setup
      Puzzle.reset!
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render' do
      assert_equal :button, el.tag_name
      assert_equal 'Hint', el.text
    end

    test 'hint button changes lines' do
      event = false
      model.puzzle.on(:lines_changed) { event = true }
      el.trigger(:click)
      assert event
    end

    test 'enabled if not autohint' do
      refute el.is(':disabled')
    end

    test 'disabled if autohint' do
      model.autohint = true
      assert el.is(':disabled')
    end

    test 're-render when autohint changes' do
      view.render
      model.autohint = true
      assert el.is(':disabled')
      model.autohint = false
      refute el.is(':disabled')
    end
  end
end
