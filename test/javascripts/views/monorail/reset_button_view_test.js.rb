module Monorail
  class ResetButtonViewTest < ViewTest
    self.view_class = ResetButtonView

    def setup
      @model = Puzzle.of_size(2)
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render' do
      assert_equal :button, el.tag_name
      assert_equal 'Reset', el.text
      assert el.prop(:disabled)
    end

    test 'enabled if history' do
      model.lines.first.next_state!
      refute el.prop(:disabled)
    end

    test 're-render when model changes' do
      view.render
      model.lines.first.next_state!
      refute el.prop(:disabled)
      model.reset!
      assert el.prop(:disabled)
    end

    test 'reset! when clicked' do
      model.lines.each &:next_state!
      el.trigger(:click)
      assert model.lines.all?(&:unknown?)
    end
  end
end
