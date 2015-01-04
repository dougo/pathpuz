require 'test_helper'

class MonorailTest < Capybara::Rails::TestCase
  test 'sanity' do
    visit root_path
    assert_selector page, 'svg'
  end

  test 'solve the trivial puzzle' do
    visit root_path
    lines_to_click = all('line[stroke="transparent"]')
    assert_equal 4, lines_to_click.length
    lines_to_click.each do |line|
      # line.click # doesn't work: https://github.com/teampoltergeist/poltergeist/issues/331
      line.trigger(:click)
    end
    painted_lines = all('line[stroke="black"]')
    assert_equal 4, painted_lines.length
    # TODO: win message?
  end
end
