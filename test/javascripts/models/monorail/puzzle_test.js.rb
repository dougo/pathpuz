require 'models/monorail/puzzle'

module Monorail
  class PuzzleTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(dot_rows lines), Puzzle.columns
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
      [2, 12, 16].each do |i|
        assert subject.lines[i].present?, "Line #{i} should be present."
        assert subject.lines[i].fixed?,   "Line #{i} should be fixed."
      end
    end

    test 'size 5' do
      subject = Puzzle.new(5)
      assert_bottom_right_dot_is_omitted subject, 5
      assert_equal 38, subject.lines.length
      assert_adjacent_dots_are_connected subject
    end

    test 'connect' do
      subject = Puzzle.new
      dot1 = Dot.new(row: 1, col: 2)
      dot2 = Dot.new(row: 3, col: 4)
      subject.connect(dot1, dot2)
      line = subject.lines.last
      assert_kind_of Line, line
      assert_equal dot1, line.dot1
      assert_equal dot2, line.dot2
    end

    test 'dot' do
      subject = Puzzle.new
      dot = subject.dot(1, 0)
      assert_equal 1, dot.row
      assert_equal 0, dot.col
      assert_equal subject.dot_rows[1][0], dot
    end

    test 'dots' do
      subject = Puzzle.new
      assert_equal [subject.dot(0, 0), subject.dot(0, 1), subject.dot(1, 0), subject.dot(1, 1)], subject.dots
    end

    test 'width and height' do
      subject = Puzzle.new(3)
      assert_equal 3, subject.width
      assert_equal 3, subject.height

      subject.dot_rows << [Dot.new(row: 3, col: 2)]
      assert_equal 3, subject.width
      assert_equal 4, subject.height

      subject.dot_rows.first << Dot.new(row: 0, col: 3)
      assert_equal 4, subject.width
      assert_equal 4, subject.height
    end

    test 'solved?' do
      subject = Puzzle.new
      event = nil
      subject.on(:solved) { event = true }
      (0..2).each { |i| subject.lines[i].present? = true }
      refute subject.solved?
      refute event
      subject.lines[3].present? = true
      assert subject.solved?
      assert event
    end

    test 'solved? for 2x3' do
      subject = Puzzle.new
      subject.dot_rows << [Dot.new(row: 2, col: 0), Dot.new(row: 2, col: 1)]
      subject.connect(subject.dot(1, 0), subject.dot(2, 0))
      subject.connect(subject.dot(1, 1), subject.dot(2, 1))
      subject.connect(subject.dot(2, 0), subject.dot(2, 1))

      (0..3).each { |i| subject.lines[i].present? = true }
      refute subject.solved?, 'Not all dots are connected.'

      (4..6).each { |i| subject.lines[i].present? = true }
      refute subject.solved?, 'Path contains branches.'

      subject.lines[3].present? = false
      assert subject.solved?
    end

    private

    def assert_has_grid_of_dots(puzzle, size)
      assert_equal size, puzzle.height
      puzzle.dot_rows.each_with_index do |row, r|
        assert_equal size, row.length
        row.each_with_index do |dot, c|
          assert_equal r, dot.row
          assert_equal c, dot.col
        end
      end
    end

    def assert_bottom_right_dot_is_omitted(puzzle, size)
      assert_equal size, puzzle.height
      assert_equal size, puzzle.width
      assert_equal size-1, puzzle.dot_rows.last.length
    end

    def assert_adjacent_dots_are_connected(puzzle)
      dots = puzzle.dot_rows
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
