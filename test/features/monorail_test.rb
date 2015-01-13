require 'test_helper'

class MonorailTest < Capybara::Rails::TestCase
  test 'sanity' do
    visit root_path
    assert_selector page, 'svg'
  end

  test 'solve the trivial puzzle' do
    visit root_path
    assert_equal 4, lines_to_click.length
    refute_text page, 'Solved!'
    lines_to_click.each do |line|
      # line.click # doesn't work: https://github.com/teampoltergeist/poltergeist/issues/331
      line.trigger(:click)
    end
    assert_equal 4, painted_lines.length
    assert_text page, 'Solved!'
  end

  test 'skip to the next puzzle' do
    visit root_path
    lines_to_click.first.trigger(:click)
    assert_equal 1, painted_lines.length
    click_on 'Next puzzle'
    assert_equal 4, lines_to_click.length
    assert_empty painted_lines
  end

  private

  def lines_to_click
    all('line[cursor="pointer"]')
  end

  def painted_lines
    all('line[stroke="black"]')
  end
end
