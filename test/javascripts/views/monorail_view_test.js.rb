require 'views/monorail_view'

class MonorailViewTest < Minitest::Test
  test 'template' do
    assert_kind_of Vienna::TemplateView, MonorailView.new
  end
end
