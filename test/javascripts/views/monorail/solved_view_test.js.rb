module Monorail
  class SolvedViewTest < ViewTest
    self.view_class = SolvedView

    def setup
      @model = Puzzle.of_size(2)
    end

    test 'initialize' do
      assert_equal model, view.model
    end

    test 'element is a g' do
      assert_equal :g, el.tag_name
      assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
    end

    test 'render unsolved' do
      assert_empty el.children
    end

    test 'render solved' do
      model.lines.each { |line| line.state = :present }

      # The bounding box of the rect can only be calculated if the element is already part of the SVG,
      # so we have to add it to a root element.
      svg = SVGElement.new(:svg).append_to_body.append(el)
      viewBox = '-1 -1 3 3'
      `svg[0].setAttribute('viewBox', viewBox)`

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
