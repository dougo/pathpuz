require 'templates/monorail'

class MonorailTemplateTest < Minitest::Test
  test 'four dots' do
    el = Element.parse Template[:monorail].render
    assert_equal :svg, el.tag_name
    assert_equal 'http://www.w3.org/2000/svg', el[:xmlns]
    dots = el.find :circle
    assert_equal 4, dots.length
    dots.each do |dot|
      assert_equal '5', dot[:r]
      assert_equal :gray, dot[:fill]
    end
  end
end
