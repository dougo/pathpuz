module Monorail
  class HintRuleViewTest < ViewTest
    self.model_class = HintRule
    self.view_class = HintRuleView

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render every_dot_has_two_lines' do
      model.type = :every_dot_has_two_lines
      assert_equal :div, el.tag_name

      label = el.children.first
      assert_equal 'Every dot has two lines', label.text

      checkbox = label.JS.contents.first
      assert_equal :input, checkbox.tag_name
      assert_equal :checkbox, checkbox[:type]
    end

    test 'render every_dot_has_only_two_lines' do
      model.type = :every_dot_has_only_two_lines
      assert_equal 'Every dot has only two lines', el.text
    end

    test 'render single_loop' do
      model.type = :single_loop
      assert_equal "Don't close a loop if it doesn't connect all dots", el.text
    end

    test 'checkbox is unchecked if model is not auto' do
      refute checked?
    end

    test 'checkbox is checked if model is auto' do
      model.auto = true
      assert checked?
    end

    test 'checkbox is updated when model changes' do
      view.render
      model.auto = true
      assert checked?
      model.auto = false
      refute checked?
    end

    test 'model is updated when checkbox changes' do
      check!
      assert model.auto
      uncheck!
      refute model.auto
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
