module Monorail
  class AutohintViewTest < ViewTest
    self.model_class = Application
    self.view_class = AutohintView

    def setup
      Puzzle.reset!
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render' do
      assert_equal :div, el.tag_name
      assert_equal :autohint, el.class_name
      label = el.find('label')
      assert_equal 1, label.length
      assert_equal 'Auto-hint', label.text
      checkbox = label.find(':checkbox')
      assert_equal 1, checkbox.length
    end

    test 'checkbox changes the model' do
      check!
      assert model.autohint
      uncheck!
      refute model.autohint
    end

    test 'unchecked if no autohint' do
      refute checked?
    end

    test 'checked if autohint' do
      model.autohint = true
      assert checked?
    end

    test 're-render when autohint changes' do
      view.render
      model.autohint = true
      assert checked?
      model.autohint = false
      refute checked?
    end

    private

    def checkbox
      el.find(':checkbox')
    end

    def checked?
      checkbox.is(':checked')
    end

    def check!
      checkbox.prop(:checked, true).trigger(:change)
    end

    def uncheck!
      checkbox.prop(:checked, false).trigger(:change)
    end
  end
end
