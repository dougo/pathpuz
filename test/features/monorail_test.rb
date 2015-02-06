require 'test_helper'

class MonorailTest < Capybara::Rails::TestCase
  setup { visit root_path }

  test 'sanity' do
    assert_selector page, 'svg'
    assert find('svg')[:viewBox]
  end

  test 'solve the trivial puzzle' do
    assert_equal 4, lines_to_click.length
    refute_text page, 'SOLVED'
    lines_to_click.each do |line|
      # line.click # doesn't work: https://github.com/teampoltergeist/poltergeist/issues/331
      line.trigger(:click)
    end
    assert_equal 4, painted_lines.length
    assert_text page, 'SOLVED'
  end

  test 'skip to the next puzzle' do
    lines_to_click.first.trigger(:click)
    assert_equal 1, painted_lines.length
    click_on 'Next puzzle'
    assert_equal 10, lines_to_click.length
    assert_empty painted_lines
  end

  test 'solve the 3x3 puzzle' do
    click_on 'Next puzzle'
    lines = lines_to_click
    # Lines are numbered like so:
    #  0 1   o-o-o
    # 2 3 4  | | |
    #  5 6   o-o-o
    # 7 8    | |
    #  9     o-o
    [0, 1, 2, 4, 6, 7, 8].each { |i| lines[i].trigger(:click) }
    refute_text page, 'SOLVED'
    lines[9].trigger(:click)
    assert_equal 8, painted_lines.length
    assert_text page, 'SOLVED'
  end

  private

  def lines_to_click
    all('line[cursor="pointer"]')
  end

  def painted_lines
    all('line[stroke="black"]')
  end
end
