require 'svg_element'

class SVGElementTest < Minitest::Test
  test 'NS' do
    assert_equal 'http://www.w3.org/2000/svg', SVGElement::NS
  end

  test 'new uses the SVG namespace' do
    el = SVGElement.new('circle')
    assert_equal SVGElement::NS, `el[0].namespaceURI`
    assert_equal 'circle', el.tag_name
  end

  test 'svg root has xmlns attr' do
    el = SVGElement.new('svg')
    assert_equal SVGElement::NS, el[:xmlns]
  end
end
