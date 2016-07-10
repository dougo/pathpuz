require 'views/pathpuz/monorail/autohint_view'

module Monorail
  class AutohintViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      Puzzle.reset!
      self.model = Application.new
      self.view = AutohintView.new(model).render
      self.el = view.element
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

    test 'checkbox reflects the model' do
      refute checked?
      self.el = AutohintView.new(Application.new(autohint: true)).render.element
      assert checked?
    end

    test 're-render when autohint changes' do
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
