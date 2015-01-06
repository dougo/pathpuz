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
    assert_equal 2, dots.select { |dot| dot.coords[:cx] == 10 }.length
    assert_equal 2, dots.select { |dot| dot.coords[:cx] == 40 }.length
    assert_equal 2, dots.select { |dot| dot.coords[:cy] == 10 }.length
    assert_equal 2, dots.select { |dot| dot.coords[:cy] == 40 }.length
  end

  test 'has four LineViews' do
    lines = view.lines
    assert_equal 4, lines.length
    lines.each { |line| assert_kind_of Monorail::LineView, line }
  end

  test 'lines form a square' do
    lines = view.lines
    assert_equal 2, lines.select { |line| line.coords[:x1] == line.coords[:x2] }.length
    assert_equal 2, lines.select { |line| line.coords[:y1] == line.coords[:y2] }.length
    assert_equal 2, lines.select { |line| line.coords[:x1] == 10 && line.coords[:y1] == 10 }.length
    assert_equal 2, lines.select { |line| line.coords[:x2] == 40 && line.coords[:y2] == 40 }.length
  end
end
