require 'templates/monorail'

class MonorailTemplateTest < Minitest::Test
  attr_accessor :el

  def setup
    self.el = Element.parse Template[:monorail].render
  end

  test 'is svg' do
    assert_equal :svg, el.tag_name
    assert_equal 'http://www.w3.org/2000/svg', el[:xmlns]
  end

  test 'has four dots' do
    dots = el.find :circle
    assert_equal 4, dots.length
    dots.each do |dot|
      assert_equal '5', dot[:r]
      assert_equal :gray, dot[:fill]
    end
    assert_equal 2, dots.filter('[cx=10]').length
    assert_equal 2, dots.filter('[cx=40]').length
    assert_equal 2, dots.filter('[cy=10]').length
    assert_equal 2, dots.filter('[cy=40]').length
  end

  test 'has four lines' do
    lines = el.find :line
    assert_equal 4, lines.length
    lines.each do |line|
      assert_equal '3', line['stroke-width']
      assert_equal :transparent, line[:stroke]
    end
    assert_equal 2, lines.select { |line| line[:x1] == line[:x2] }.length
    assert_equal 2, lines.select { |line| line[:y1] == line[:y2] }.length
    assert_equal 2, lines.filter('[x1=10][y1=10]').length
    assert_equal 2, lines.filter('[x2=40][y2=40]').length
  end
end
