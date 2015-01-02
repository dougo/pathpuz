require 'test_helper'

class MonorailTest < Capybara::Rails::TestCase
  test 'sanity' do
    visit root_path
    assert_selector page, 'svg'
  end

  test 'solve the trivial puzzle' do
    visit root_path
    lines = all('line')
    assert_equal 4, lines.length
    lines.each do |line|
      # line.click # doesn't work: https://github.com/teampoltergeist/poltergeist/issues/331
      line.trigger(:click)
      assert_equal 'black', line[:stroke]
    end
    # TODO: win message?
  end
end
