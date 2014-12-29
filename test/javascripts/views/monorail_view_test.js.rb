require 'views/monorail_view'

class MonorailViewTest < Minitest::Test
  test 'tag_name' do
    assert_equal 'p', MonorailView.new.tag_name
  end

  test 'render' do
    view = MonorailView.new
    view.render
    cells = view.element.find('td')
    assert_equal 4, cells.length
    cells.each { |cell| assert_equal '@', cell.text }
  end
end
