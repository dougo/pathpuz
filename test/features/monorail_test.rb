require 'test_helper'

class MonorailTest < Capybara::Rails::TestCase
  test 'sanity' do
    visit root_path
    assert_selector page, 'p', :text => 'Soon there will be a puzzle here.'
  end
end
