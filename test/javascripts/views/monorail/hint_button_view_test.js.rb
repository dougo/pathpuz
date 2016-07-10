require 'views/pathpuz/monorail/hint_button_view'

module Monorail
  class HintButtonViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      Puzzle.reset!
      self.model = Application.new
      self.view = HintButtonView.new(model).render
      self.el = view.element
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

    test 'disabled if autohint' do
      refute el.is(':disabled')
      view = HintButtonView.new(Application.new(autohint: true)).render
      assert view.element.is(':disabled')
    end

    test 're-render when autohint changes' do
      model.autohint = true
      assert el.is(':disabled')
      model.autohint = false
      refute el.is(':disabled')
    end
  end
end
