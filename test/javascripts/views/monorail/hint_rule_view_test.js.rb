module Monorail
  class HintRuleViewTest < ViewTest
    self.model_class = HintRule
    self.view_class = HintRuleView

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render' do
      assert_equal :label, el.tag_name
      assert_equal 'Complete a completable dot', el.text

      Element.expose :contents
      checkbox = el.contents.first
      assert_equal :input, checkbox.tag_name
      assert_equal :checkbox, checkbox[:type]
    end

    test 'checkbox is checked if model is enabled' do
      assert checked?
    end

    test 'checkbox is unchecked if model is disabled' do
      model.disabled = true
      refute checked?
    end

    test 'checkbox is updated when model changes' do
      view.render
      model.disabled = true
      refute checked?
      model.disabled = false
      assert checked?
    end

    test 'model is updated when checkbox changes' do
      uncheck!
      assert model.disabled
      check!
      refute model.disabled
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
