class MonorailViewTest < Minitest::Test
  def test_tag_name
    assert_equal 'p', MonorailView.new.tag_name
  end
end
