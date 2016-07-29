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

    test 'enabled if hints available' do
      assert model.can_hint?
      refute model.puzzle.solved?
      refute el.is(':disabled')
    end

    test 'disabled if no hints available' do
      model.puzzle = Puzzle.of_size(3)
      model.puzzle.lines.each &:next_state!
      refute model.can_hint?
      refute model.puzzle.solved?
      assert el.is(':disabled')
    end

    test 'disabled if solved' do
      model.puzzle = Puzzle.of_size(3)
      model.hint! while model.can_hint?
      model.puzzle.lines.select(&:absent?).each { |l| l.state = nil }
      assert model.can_hint?
      assert model.puzzle.solved?
      assert el.is(':disabled')
    end

    test 're-render when lines changed or undone' do
      model.puzzle = Puzzle.find(5)
      view.render
      model.hint! while model.can_hint?
      assert el.is(':disabled')
      model.puzzle.undo!
      refute el.is(':disabled')
    end
  end
end
