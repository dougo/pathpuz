module Monorail
  class HintButtonViewTest < ViewTest
    self.model_class = Application
    self.view_class = HintButtonView

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

    test 'disabled if solved' do
      model.puzzle.lines.each { |l| l.state = :present }
      assert el.is(':disabled')
    end

    test 're-render when autohint changes' do
      model.puzzle = Puzzle.find(4) # so that it won't be auto-solved!
      view.render
      model.autohint = true
      assert el.is(':disabled')
      model.autohint = false
      refute el.is(':disabled')
    end

    test 're-render when solved' do
      view.render
      model.puzzle.dots.first.complete!
      model.puzzle.dots.last.complete!
      assert el.is(':disabled')
    end
  end
end
