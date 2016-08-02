module Monorail
  class UndoButtonViewTest < ViewTest
    self.view_class = UndoButtonView

    def setup
      @model = Puzzle.of_size(2)
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render' do
      assert_equal :button, el.tag_name
      assert_equal 'Undo', el.text
      assert el.prop('disabled')
    end

    test 'enabled if history' do
      model.lines.first.next_state!
      refute el.prop('disabled')
    end

    test 'disabled if solved' do
      model.dots.first.complete!
      model.dots.last.complete!
      assert el.prop('disabled')
    end

    test 're-render when model changes' do
      view.render
      model.lines.first.next_state!
      refute el.prop('disabled')
      model.undo!
      assert el.prop('disabled')
    end

    test 'undo when clicked' do
      model.lines.first.next_state!
      el.trigger(:click)
      assert model.lines.first.unknown?
    end
  end
end
