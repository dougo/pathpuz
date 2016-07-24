module Monorail
  class ApplicationViewTest < ViewTest
    self.model_class = Application
    self.view_class = ApplicationView

    def setup
      unless Element.id(:puzzle)
        Element.new.send(:id=, :puzzle).append_to(Document.body)
      end
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render' do
      assert_equal :puzzle, el.id

      child = el.children.first
      assert_equal :p, child.tag_name
      assert_equal 'Build a monorail loop that visits every dot.', child.text

      child = child.next
      assert_equal :svg, child.tag_name

      child = child.next
      assert_equal :div, child.tag_name
      assert_equal :autohint, child.class_name

      child = child.next
      assert_equal :div, child.tag_name

      button = child.children.first
      assert_equal :button, button.tag_name
      assert_equal 'Previous puzzle', button.text
      assert_equal :prev, button.class_name

      button = button.next
      assert_equal 'Undo', button.text

      button = button.next
      assert_equal 'Hint', button.text

      button = button.next
      assert_equal :button, button.tag_name
      assert_equal 'Next puzzle', button.text
      assert_equal :next, button.class_name

      child = child.next
      assert_equal :div, child.tag_name
      assert_equal :hint_rules, child.class_name

      hint_rules_elt = child.children.first
      assert_equal :h3, hint_rules_elt.tag_name
      assert_equal 'Hint Rules', hint_rules_elt.text

      assert_equal 3, hint_rules_elt.JS.nextAll.length
    end

    test 'next/prev buttons' do
      prev = el.find('.prev')
      assert prev.prop('disabled')
      el.find('.next').trigger(:click); model.router.update
      assert_equal 1, model.puzzle.id
      assert_equal 1, view.element.find('svg').length, 'view element should be emptied'

      prev = el.find('.prev')
      refute prev.prop('disabled')
      prev.trigger(:click); model.router.update
      assert_equal 0, model.puzzle.id
    end

    test 'render when the model changes its puzzle' do
      svg = el.find('svg')
      model.puzzle = Puzzle.find(1)
      refute_equal svg, el.find('svg')
    end
  end
end
