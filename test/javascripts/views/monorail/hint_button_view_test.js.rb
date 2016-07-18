module Monorail
  class HintButtonViewTest < ViewTest
    self.view_class = HintButtonView

    def setup
      @model = Puzzle.of_size(2)
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
      model.on(:lines_changed) { event = true }
      el.trigger(:click)
      assert event
    end

    test 'enabled if hints available' do
      assert model.can_hint?
      refute model.solved?
      refute el.is(':disabled')
    end

    test 'disabled if no hints available' do
      @model = Puzzle.of_size(3)
      model.lines.each &:next_state!
      refute model.can_hint?
      refute model.solved?
      assert el.is(':disabled')
    end

    test 'disabled if solved' do
      @model = Puzzle.of_size(3)
      model.hint! while model.can_hint?
      model.lines.select(&:absent?).each { |l| l.state = nil }
      assert model.can_hint?
      assert model.solved?
      assert el.is(':disabled')
    end

    test 're-render when lines changed or undone' do
      @model = Puzzle.find(4)
      view.render
      model.hint! while model.can_hint?
      assert el.is(':disabled')
      model.undo!
      refute el.is(':disabled')
    end
  end
end
