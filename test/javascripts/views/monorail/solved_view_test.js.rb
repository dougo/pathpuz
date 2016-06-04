require 'views/pathpuz/monorail/solved_view'

module Monorail
  class SolvedViewTest < Minitest::Test
    attr_accessor :model, :view, :el

    def setup
      self.model = Puzzle.new
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
      skip 'calculation of text size is flaky'
      model.lines.each { |line| line.state = :present }
      view = SolvedView.new(model)
      el = view.element

      # The bounding box of the text can only be calculated if the element is already part of the SVG,
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

      text = el.find(:text)
      assert_equal :solved, text[:class]
      assert_equal 'SOLVED', text.text

      bbox = `text[0].getBBox()` # Note that this is the untransformed bounding box!
      assert_equal 0, `bbox.x`
      assert_equal 0, `bbox.y`
      # assert_equal 64, `bbox.width`
      # assert_equal 19, `bbox.height`
      assert_equal 60, `bbox.width` # TODO: Apparently these depend on what fonts the system has?
      assert_equal 20, `bbox.height`

      # The text width should be scaled to the width of the viewport.
      scale = 3 / `bbox.width`

      # The left edge of the text should be at the left edge of the viewport.
      dx = -1

      # The text should be vertically centered, so its top should be halfway down the viewport minus half the
      # (scaled) text height.
      dy = (-1 + 3/2) - (scale * `bbox.height` / 2)

      assert_equal "translate(#{dx} #{dy}) scale(#{scale})", text[:transform]
    end

    test 're-render when solved' do
      view.render
      model.lines.each { |line| line.state = :present }
      refute_empty el.children
    end
  end
end
