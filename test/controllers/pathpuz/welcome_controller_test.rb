require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test 'index should have root element' do
    get pathpuz.root_url
    assert_response :success
    assert_select '#puzzle'
    assert_select 'title', 'Path Puzzles'
    assert_select 'h1', 'Monorail Puzzle'
    assert_select '#forkongithub'
  end
end
