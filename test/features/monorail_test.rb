require 'test_helper'

class MonorailTest < Capybara::Rails::TestCase
  setup { visit pathpuz.root_path }

  test 'sanity' do
    assert_selector page, 'svg'
    assert find('svg')[:viewBox]
  end

  test 'solve the trivial puzzle' do
    assert_equal 4, dots.length
    assert_equal 4, lines_to_click.length
    refute_text page, 'SOLVED'
    lines_to_click.each do |line|
      # line.click # doesn't work: https://github.com/teampoltergeist/poltergeist/issues/331
      line.trigger(:click)
    end
    assert_equal 4, black_lines.length
    assert_text page, 'SOLVED'
  end

  test 'skip to the next puzzle' do
    lines_to_click.first.trigger(:click)
    assert_equal 1, black_lines.length
    click_on 'Next puzzle'
    assert_equal 8, dots.length
    assert_equal 10, lines_to_click.length
    assert_empty black_lines
  end

  test 'solve the 3x3 puzzle' do
    click_on 'Next puzzle'
    lines = lines_to_click
    # Lines are numbered like so:
    #  0 2   o-o-o
    # 1 3 4  | | |
    #  5 7   o-o-o
    # 6 8    | |
    #  9     o-o
    # TODO: find these lines by x1,y1,x2,y2 instead of depending on order
    [0, 2, 4, 7, 8, 9, 6].each { |i| lines[i].trigger(:click) }
    refute_text page, 'SOLVED'
    lines[1].trigger(:click)
    assert_equal 8, black_lines.length
    assert_text page, 'SOLVED'
  end

  test '4x4 puzzle has fixed lines' do
    click_on 'Next puzzle'
    click_on 'Next puzzle'
    assert_equal 16, dots.length
    assert_equal 21, lines_to_click.length
    assert_equal 3, gray_lines.length
  end

  private

  def dots
    all('circle')
  end

  def lines_to_click
    all('line[cursor="pointer"]')
  end

  def black_lines
    all('line[stroke="black"]')
  end

  def gray_lines
    all('line[stroke="gray"]')
  end
end
