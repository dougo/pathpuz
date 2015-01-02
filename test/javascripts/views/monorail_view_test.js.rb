require 'views/monorail_view'

class MonorailViewTest < Minitest::Test
  test 'template' do
    assert_kind_of Vienna::TemplateView, MonorailView.new
  end

  test 'lines can be clicked' do
    view = MonorailView.new
    view.render
    el = view.element
    lines = el.find :line
    lines.each do |line|
      assert_equal :transparent, line[:stroke]
      line.trigger(:click)
      assert_equal :black, line[:stroke]
      line.trigger(:click)
      assert_equal :transparent, line[:stroke]
    end
  end
end
