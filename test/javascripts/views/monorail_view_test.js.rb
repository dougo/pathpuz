require 'views/monorail_view'

class MonorailViewTest < Minitest::Test
  test 'tag_name' do
    assert_equal 'p', MonorailView.new.tag_name
  end

  test 'render' do
    view = MonorailView.new
    view.render
    assert_equal 'Soon there will be a puzzle here.', view.element.html
  end
end
