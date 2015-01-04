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

  test 'renders four dots' do
    dots = el.find(:circle)
    assert_equal 2, dots.filter('[cx=10]').length
    assert_equal 2, dots.filter('[cx=40]').length
    assert_equal 2, dots.filter('[cy=10]').length
    assert_equal 2, dots.filter('[cy=40]').length
  end

  test 'has four LineViews' do
    lines = view.lines
    assert_equal 4, lines.length
    lines.each { |line| assert_kind_of Monorail::LineView, line }
  end

  test 'renders four lines' do
    lines = el.find(:line)
    assert_equal 2, lines.select { |line| line[:x1] == line[:x2] }.length
    assert_equal 2, lines.select { |line| line[:y1] == line[:y2] }.length
    assert_equal 2, lines.filter('[x1=10][y1=10]').length
    assert_equal 2, lines.filter('[x2=40][y2=40]').length
  end
end
