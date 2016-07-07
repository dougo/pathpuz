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
    refute_solved
    lines_to_click.each &:click
    assert_equal 4, black_lines.length
    assert_solved
  end

  test 'solve the trivial puzzle by clicking on dots' do
    click_dot(0, 0)
    click_dot(1, 1)
    assert_equal 4, black_lines.length
    assert_solved
  end

  test 'skip to the next puzzle' do
    click_line([0,0], [0,1])
    assert_equal 1, black_lines.length
    next_puzzle!
    assert_equal 8, dots.length
    assert_equal 10, lines_to_click.length
    assert_empty black_lines
  end

  test 'back button' do
    next_puzzle!
    # TODO: this causes a Capybara::Poltergeist::TimeoutError
    # page.go_back
    page.execute_script("history.back()")
    assert_equal 4, dots.length
  end

  test 'solve the 3x3 puzzle' do
    next_puzzle!
    click_line([0,0], [0,1])
    click_line([0,1], [0,2])
    click_line([0,2], [1,2])
    click_line([1,1], [1,2])
    click_line([1,1], [2,1])
    click_line([2,0], [2,1])
    click_line([1,0], [2,0])
    refute_solved
    click_line([0,0], [1,0])
    assert_equal 8, black_lines.length
    assert_solved
  end

  test 'solve the 3x3 puzzle by clicking on dots' do
    next_puzzle!
    click_dot(0, 0)
    click_dot(0, 2)
    click_dot(1, 2)
    click_dot(2, 0)
    refute_solved
    click_dot(2, 1)
    assert_equal 8, black_lines.length
    assert_solved
  end

  test 'solve the easier 4x4 puzzle using only hints' do
    next_puzzle!
    next_puzzle!
    15.times { click_on 'Hint' }
    assert_solved
  end

  test 'solve the harder 4x4 puzzle' do
    next_puzzle!
    next_puzzle!
    next_puzzle!
    assert_equal 16, dots.length
    assert_equal 21, lines_to_click.length
    assert_equal 3, gray_lines.length
    # Corners:
    click_dot(0, 0)
    click_dot(0, 3)
    click_dot(3, 0)
    click_dot(3, 3)
    # Completed dots:
    click_dot(0, 1)
    click_dot(0, 2)
    click_dot(2, 2)
    # Dots with only one unknown:
    click_dot(2, 3)
    click_dot(3, 2)
    # More completed dots:
    click_dot(1, 3)
    click_dot(3, 1)
    # Another dot with only one unknown:
    click_dot(1, 2)

    # The grid now looks like this:
    # o---o---o---o
    # |   x   x   |
    # o   o---o x o
    #         |   |
    # o   o---o x o
    # |   x   x   |
    # o---o---o---o 

    assert_equal 6, red_exes.length
    assert_equal 11, black_lines.length
    refute_solved

    # If lines [1,0],[2,0] and [1,1],[2,1] were present, there would be two separate loops,
    # so [1,0],[1,1] and [2,0],[2,1] must be present.
    click_line([1,0], [1,1])
    click_line([2,0], [2,1])
    assert_solved
  end

  private

  def assert_solved
    assert_selector '.solved'
  end

  def refute_solved
    refute_selector '.solved'
  end

  def dots
    @dots ||= all('circle')
  end

  def dot(row, col)
    find("circle[cx='#{col}'][cy='#{row}']")
  end

  def click_dot(row, col)
    dot(row, col).click
  end

  def lines_to_click
    @lines_to_click ||= all('line[cursor="pointer"]')
  end

  def dot_rect(row, col)
    page.evaluate_script("$('circle[cx=\"#{col}\"][cy=\"#{row}\"]')[0].getBoundingClientRect()")
  end

  def dot_midpoint(row, col)
    rect = dot_rect(row, col)
    [rect['left'] + rect['width']/2, rect['top'] + rect['height']/2]
  end

  def line_midpoint(dot1, dot2)
    m1, m2 = dot_midpoint(*dot1), dot_midpoint(*dot2)
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
