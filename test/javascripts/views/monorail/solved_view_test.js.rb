require 'views/monorail/solved_view'

module Monorail
  class SolvedViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      self.model = Puzzle.new
      self.view = SolvedView.new(model)
      self.el = view.element
    end

    test 'element is a p' do
      assert_equal :p, el.tag_name
      assert_equal :solved, el.class_name
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'render unsolved' do
      view.render
      assert_equal '', el.text
    end

    test 'render solved' do
      model.lines.each { |line| line.present? = true }
      view.render
      assert_equal 'Solved!', el.text
    end

    test 're-render when solved' do
      view.render
      model.lines.each { |line| line.present? = true }
      assert_equal 'Solved!', el.text
    end
  end
end
