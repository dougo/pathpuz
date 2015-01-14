require 'models/monorail/puzzle'

module Monorail
  class PuzzleTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(dots lines), Puzzle.columns
    end

    test 'size 2' do
      subject = Puzzle.new
      assert_has_grid_of_dots subject, 2
      assert_equal 4, subject.lines.length
      assert_adjacent_dots_are_connected subject
    end

    test 'size 3' do
      subject = Puzzle.new(3)
      assert_bottom_right_dot_is_omitted subject, 3
      assert_equal 10, subject.lines.length
      assert_adjacent_dots_are_connected subject
    end

    test 'size 4' do
      subject = Puzzle.new(4)
      assert_has_grid_of_dots subject, 4
      assert_equal 24, subject.lines.length
      assert_adjacent_dots_are_connected subject
    end

    test 'size 5' do
      subject = Puzzle.new(5)
      assert_bottom_right_dot_is_omitted subject, 5
      assert_equal 38, subject.lines.length
      assert_adjacent_dots_are_connected subject
    end

    test 'width and height' do
      subject = Puzzle.new(3)
      assert_equal 3, subject.width
      assert_equal 3, subject.height

      # Add a new row:
      subject.dots << [Dot.new(row: 3, col: 2)]
      assert_equal 3, subject.width
      assert_equal 4, subject.height

      # Add a dot to the first row:
      subject.dots.first << Dot.new(row: 0, col: 3)
      assert_equal 4, subject.width
      assert_equal 4, subject.height
    end

    test 'solved?' do
      subject = Puzzle.new
      event = nil
      subject.on(:solved) { event = true }
      subject.lines[0].present? = true
      subject.lines[1].present? = true
      subject.lines[2].present? = true
      refute subject.solved?
      refute event
      subject.lines[3].present? = true
      assert subject.solved?
      assert event
    end

    private

    def assert_has_grid_of_dots(puzzle, size)
      assert_equal size, puzzle.dots.length
      puzzle.dots.each_with_index do |row, r|
        assert_equal size, row.length
        row.each_with_index do |dot, c|
          assert_equal r, dot.row
          assert_equal c, dot.col
        end
      end
    end

    def assert_bottom_right_dot_is_omitted(puzzle, size)
      assert_equal size, puzzle.dots.length
      assert_equal size, puzzle.dots.first.length
      assert_equal size-1, puzzle.dots.last.length
    end

    def assert_adjacent_dots_are_connected(puzzle)
      dots = puzzle.dots
      lines = puzzle.lines
      (0...dots.length).each do |r|
        row = dots[r]
        (0...row.length).each do |c|
          unless c+1 == row.length
            assert_equal 1, lines.select { |line| line.dot1 == dots[r][c] && line.dot2 == dots[r][c+1] }.length
          end
          unless r+1 == dots.length || c == dots[r+1].length
            assert_equal 1, lines.select { |line| line.dot1 == dots[r][c] && line.dot2 == dots[r+1][c] }.length
          end
        end
      end
    end
  end
end
