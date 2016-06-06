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
    click_lines(*0..3)
    assert_equal 4, black_lines.length
    assert_text page, 'SOLVED'
  end

  test 'solve the trivial puzzle by clicking on dots' do
    dots.first.click
    dots.last.click
    assert_equal 4, black_lines.length
    assert_text page, 'SOLVED'
  end

  test 'skip to the next puzzle' do
    click_lines(0)
    assert_equal 1, black_lines.length
    next_puzzle!
    assert_equal 8, dots.length
    assert_equal 10, lines_to_click.length
    assert_empty black_lines
  end

  test 'solve the 3x3 puzzle' do
    next_puzzle!
    # Lines are numbered like so:
    #  0 2   o-o-o
    # 1 3 4  | | |
    #  5 7   o-o-o
    # 6 8    | |
    #  9     o-o
    # TODO: find these lines by x1,y1,x2,y2 instead of depending on order
    click_lines(0, 2, 4, 7, 8, 9, 6)
    refute_text page, 'SOLVED'
    click_lines(1)
    assert_equal 8, black_lines.length
    assert_text page, 'SOLVED'
  end

  test 'solve the 3x3 puzzle by clicking on dots' do
    next_puzzle!
    # Dots are numbered like so:
    # 0 1 2  o-o-o
    #        | | |
    # 3 4 5  o-o-o
    #        | |
    # 6 7    o-o
    click_dots(0, 2, 5, 6)
    refute_text page, 'SOLVED'
    dots[7].click
    assert_equal 8, black_lines.length
    assert_text page, 'SOLVED'
  end

  test 'solve the 4x4 puzzle' do
    next_puzzle!
    next_puzzle!
    assert_equal 16, dots.length
    assert_equal 21, lines_to_click.length
    assert_equal 3, gray_lines.length
    # Corners:
    click_dots(0, 3, 12, 15)
    # Completed dots:
    click_dots(1, 2, 10)
    # Dots with only one unknown:
    click_dots(11, 14)
    # More completed dots:
    click_dots(7, 13)
    # Another dot with only one unknown:
    click_dots(6)

    # The grid now looks like this (gray lines are unclickable, thus unnumbered):
    #    0       3    o---o---o---o
    #  1   2   4   5  |   x   x   |
    #    6   8  10    o   o---o x o
    #  7   9      11          |   |
    #   12      15    o   o---o x o
    # 13  14  16  17  |   x   x   |
    #   18  19  20    o---o---o---o
    assert_equal 6, red_exes.length
    assert_equal 11, black_lines.length
    refute_text page, 'SOLVED'

    # If lines 7 and 9 were present, there would be two separate loops, so 6 and 12 must be present.
    click_lines(6, 12) # TODO: refer to lines by coords! the index order is crazy!
    assert_text page, 'SOLVED'
  end

  private

  def dots
    @dots ||= all('circle')
  end

  def click_dots(*indices)
    indices.each { |i| dots[i].click }
  end

  def lines_to_click
    @lines_to_click ||= all('line[cursor="pointer"]')
  end

  def click_lines(*indices)
    # TODO: line.click still doesn't work for some reason-- a dot overlaps??
    indices.each { |i| lines_to_click[i].trigger(:click) }
  end

  def next_puzzle!
    click_on 'Next puzzle'
    @dots = @lines_to_click = nil
  end

  def black_lines
    all('line[stroke="black"]')
  end

  def gray_lines
    all('line[stroke="gray"]')
  end

  def red_exes
    all('path[stroke="red"]')
  end
end
