require 'views/pathpuz/monorail/solved_view'

module Monorail
  class SolvedViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      self.model = Puzzle.of_size(2)
      self.view = SolvedView.new(model)
      self.el = view.element
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'element is a g' do
      assert_equal :g, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
    end

    test 'render unsolved' do
      assert_equal view, view.render
      assert_empty el.children
    end

    test 'render solved' do
      model.lines.each { |line| line.state = :present }
      view = SolvedView.new(model)
      el = view.element

      # The bounding box of the rect can only be calculated if the element is already part of the SVG,
      # so we have to add it to a root element before rendering.
      svg = SVGElement.new(:svg).append_to_body.append(el)
      svg[:height] = 500
      svg[:width] = 500
      viewBox = '-1 -1 3 3'
      `svg[0].setAttribute('viewBox', viewBox)`
      view.render

      rect = el.find(:rect)
      assert_equal :transparent, rect[:fill]

      # The rect should cover the entire viewport.
      bbox = `rect[0].getBBox()`
      assert_equal -1, `bbox.x`
      assert_equal -1, `bbox.y`
      assert_equal 3, `bbox.width`
      assert_equal 3, `bbox.height`
    end
  end
end
