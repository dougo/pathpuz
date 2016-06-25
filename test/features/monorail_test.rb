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
    lines_to_click.each &:click
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
    click_line(0, 1)
    assert_equal 1, black_lines.length
    next_puzzle!
    assert_equal 8, dots.length
    assert_equal 10, lines_to_click.length
    assert_empty black_lines
  end

  test 'solve the 3x3 puzzle' do
    next_puzzle!
    # Dots are numbered like so:
    # 0---1---2
    # |   |   |
    # 3---4---5
    # |   |
    # 6---7
    click_line(0, 1)
    click_line(1, 2)
    click_line(2, 5)
    click_line(4, 5)
    click_line(4, 7)
    click_line(6, 7)
    click_line(3, 6)
    refute_text page, 'SOLVED'
    click_line(0, 3)
    assert_equal 8, black_lines.length
    assert_text page, 'SOLVED'
  end

  test 'solve the 3x3 puzzle by clicking on dots' do
    next_puzzle!
    click_dots(0, 2, 5, 6)
    refute_text page, 'SOLVED'
    click_dots(7)
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

    # The grid now looks like this:
    #  0---1---2---3
    #  |   x   x   |
    #  4   5---6 x 7
    #          |   |
    #  8   9--10 x 11
    #  |   x   x   |
    # 12--13--14---15 

    assert_equal 6, red_exes.length
    assert_equal 11, black_lines.length
    refute_text page, 'SOLVED'

    # If lines 4,8 and 5,9 were present, there would be two separate loops, so 4,5 and 8,9 must be present.
    click_line(4, 5)
    click_line(8, 9)
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

  def dot_center(dot)
    circle = dots[dot]
    [circle['cx'], circle['cy']]
  end

  def dot_rect(x, y)
    page.evaluate_script("$('circle[cx=\"#{x}\"][cy=\"#{y}\"]')[0].getBoundingClientRect()")
  end

  def dot_midpoint(dot)
    x, y = dot_center(dot)
    rect = dot_rect(x, y)
    [rect['left'] + rect['width']/2, rect['top'] + rect['height']/2]
  end

  def line_midpoint(dot1, dot2)
    m1, m2 = dot_midpoint(dot1), dot_midpoint(dot2)
    [(m1[0]+m2[0])/2, (m1[1]+m2[1])/2]
  end

  def click_line(dot1, dot2)
    x, y = line_midpoint(dot1, dot2)
    page.driver.click(x, y)
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
