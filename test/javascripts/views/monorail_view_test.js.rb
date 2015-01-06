require 'views/monorail_view'

class MonorailViewTest < Minitest::Test
  attr_accessor :view, :el

  def setup
    self.view = MonorailView.new
    view.render
    self.el = view.element
  end

  test 'is svg' do
    assert_equal :svg, el.tag_name
    assert_equal SVGElement::NS, `#{el}[0].namespaceURI`
    assert_equal SVGElement::NS, el[:xmlns]
  end

  test 'has four DotViews' do
    dots = view.dots
    assert_equal 4, dots.length
    dots.each { |dot| assert_kind_of Monorail::DotView, dot }
  end

  test 'dots form a square' do
    dots = view.dots
    assert_equal 2, dots.select { |dot| dot.model[:row] == 0 }.length
    assert_equal 2, dots.select { |dot| dot.model[:row] == 1 }.length
    assert_equal 2, dots.select { |dot| dot.model[:col] == 0 }.length
    assert_equal 2, dots.select { |dot| dot.model[:col] == 1 }.length
  end

  test 'has four LineViews' do
    lines = view.lines
    assert_equal 4, lines.length
    lines.each { |line| assert_kind_of Monorail::LineView, line }
  end

  test 'lines form a square' do
    lines = view.lines
    assert_equal 2, lines.select { |line| line.model.dot1[:row] == line.model.dot2[:row] }.length
    assert_equal 2, lines.select { |line| line.model.dot1[:col] == line.model.dot2[:col] }.length
    assert_equal 2, lines.select { |line| line.model.dot1[:row] == 0 && line.model.dot1[:col] == 0 }.length
    assert_equal 2, lines.select { |line| line.model.dot2[:row] == 1 && line.model.dot2[:col] == 1 }.length
  end
end
