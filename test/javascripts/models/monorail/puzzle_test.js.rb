require 'models/pathpuz/monorail/puzzle'

module Monorail
  class PuzzleTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(lines), Puzzle.columns
    end

    test 'lines= creates models' do
      subject = Puzzle.new
      subject.lines = [{dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                       {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                       {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}, state: :present},
                       {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}}]
      assert_square_of_size(subject, 2)
      assert subject.lines[2].present?
    end

    test 'find uses identity map' do
      p1 = Puzzle.find(0)
      lines = p1.lines
      p2 = Puzzle.find(0)
      assert_same p1, p2
      assert_same lines, p2.lines
    end

    test 'puzzle 0' do
      subject = Puzzle.find(0)
      assert_equal 0, subject.id
      assert_square_of_size(subject, 2)
    end

    test 'puzzle 1' do
      subject = Puzzle.find(1)
      assert_equal 1, subject.id
      assert_square_of_size(subject, 3)
    end

    test 'puzzle 2' do
      subject = Puzzle.find(2)
      assert_equal 2, subject.id
      assert_square_of_size(subject, 4)
      assert_has_fixed_lines(subject, [[1,2],[1,3]], [[1,2],[2,2]])
    end

    test 'puzzle 3' do
      subject = Puzzle.find(3)
      assert_equal 3, subject.id
      assert_square_of_size(subject, 4)
      assert_has_fixed_lines(subject, [[0,1],[0,2]], [[1,2],[2,2]], [[2,1],[2,2]])
    end

    test 'puzzle 4' do
      subject = Puzzle.find(4)
      assert_equal 4, subject.id
      assert_square_of_size(subject, 5)
      assert_has_fixed_lines(subject, [[1,2],[1,3]], [[2,0],[2,1]], [[2,1],[2,2]])
    end

    test 'puzzle 5' do
      subject = Puzzle.find(5)
      assert_equal 5, subject.id
      assert_square_of_size(subject, 6)
    end

    test 'of_size' do
      (2..7).each do |size|
        subject = Puzzle.of_size(size)
        assert_square_of_size(subject, size)
        assert_equal subject.lines, subject.lines.select(&:unknown?)
      end
    end

    test 'dot' do
      subject = Puzzle.of_size(2)
      assert_equal 0, subject.dot(0, 1).row
      assert_equal 1, subject.dot(0, 1).col
      assert_nil subject.dot(2, 1)
      assert_nil subject.dot(1, 2)
    end

    test 'dots' do
      subject = Puzzle.of_size(2)
      dots = subject.dots
      assert_equal 4, dots.length
      (0..1).each do |r|
        (0..1).each do |c|
          assert_equal 1, dots.count { |dot| dot.row == r && dot.col == c }
        end
      end
    end

    test 'width and height' do
      json = Puzzle.json_for_size(3)
      subject = Puzzle.new(json)
      assert_equal 3, subject.width
      assert_equal 3, subject.height

      json[:lines] << { dot1: { row: 2, col: 2 }, dot2: { row: 3, col: 2 } }
      subject = Puzzle.new(json)
      assert_equal 3, subject.width
      assert_equal 4, subject.height

      json[:lines] << { dot1: { row: 0, col: 2 }, dot2: { row: 0, col: 3 } }
      subject = Puzzle.new(json)
      assert_equal 4, subject.width
      assert_equal 4, subject.height
    end

    test 'solved?' do
      subject = Puzzle.of_size(2)
      (0..2).each { |i| subject.lines[i].state = :present }
      refute subject.solved?
      subject.lines[3].state = :present
      assert subject.solved?
    end

    test 'solved? for 2x3' do
      json = Puzzle.json_for_size(2)
      json[:lines] << { dot1: { row: 1, col: 0 }, dot2: { row: 2, col: 0 } }
      json[:lines] << { dot1: { row: 1, col: 1 }, dot2: { row: 2, col: 1 } }
      json[:lines] << { dot1: { row: 2, col: 0 }, dot2: { row: 2, col: 1 } }
      subject = Puzzle.new(json)

      (0..3).each { |i| subject.lines[i].state = :present }
      refute subject.solved?, 'Not all dots are connected.'

      (4..6).each { |i| subject.lines[i].state = :present }
      refute subject.solved?, 'Path contains branches.'

      subject.lines[3].state = nil
      assert subject.solved?
    end

    test 'solved event' do
      subject = Puzzle.of_size(2)
      subject.lines.each { |l| l.state = :present }
      event = nil
      subject.on(:solved) { event = true }
      subject.trigger(:lines_changed)
      assert event
    end

    test 'find_completable_dot' do
      subject = Puzzle.of_size(3)
      dot = subject.find_completable_dot
      assert_equal [0, 0], [dot.row, dot.col]
      assert_equal :present, dot.completable?

      dot.complete!
      line = subject.lines.find { |l| l.dot1.row == 0 && l.dot1.col == 1 && l.dot2.row == 0 && l.dot2.col == 2 }
      line.state = :present
      dot = subject.find_completable_dot
      assert_equal [0, 1], [dot.row, dot.col]
      assert_equal :absent, dot.completable?
      
      subject.lines.each { |l| l.state = :present }
      assert_nil subject.find_completable_dot
    end

    test 'hint! completes a dot' do
      subject = Puzzle.of_size(2)
      subject.hint!
      assert_equal 2, subject.dots.first.present_lines.length

      subject.lines.each { |l| l.state = :present }
      subject.hint! # does nothing, but test that it doesn't raise an error
    end

    test 'lines_changed event when line goes to next state' do
      subject = Puzzle.of_size(2)
      lines_changed = nil
      subject.on(:lines_changed) { |*lines| lines_changed = lines }
      line = subject.lines.first
      line.next_state!
      assert_equal [line], lines_changed
    end

    test 'lines_changed event when dot completed' do
      subject = Puzzle.of_size(2)
      lines_changed = nil
      subject.on(:lines_changed) { |*lines| lines_changed = lines }
      dot = subject.dots.first
      dot.complete!
      assert_equal dot.lines, lines_changed
    end

    private

    def assert_square_of_size(puzzle, size)
      assert_has_grid_of_dots(puzzle, size)
      assert_bottom_right_dot_is_omitted(puzzle, size) if size.odd?
      assert_has_expected_num_lines(puzzle, size)
      assert_adjacent_dots_are_connected(puzzle)
    end

    def assert_has_grid_of_dots(puzzle, size)
      (0...size).each do |r|
        (0...size).each do |c|
          unless size.odd? && r == size-1 && c == size-1
            dot = puzzle.dot(r, c)
            assert_equal r, dot.row
            assert_equal c, dot.col
          end
        end
      end
    end

    def assert_bottom_right_dot_is_omitted(puzzle, size)
      assert_equal size, puzzle.height
      assert_equal size, puzzle.width
      assert_nil puzzle.dot(size-1, size-1)
    end

    def assert_has_expected_num_lines(puzzle, size)
      expected_num_lines = 2*(size-1)**2 + 2*(size-1)
      expected_num_lines -= 2 if size.odd?
      assert_equal expected_num_lines, puzzle.lines.length
    end

    def assert_adjacent_dots_are_connected(puzzle)
      (0...puzzle.height).each do |r|
        (0...puzzle.width).each do |c|
          dot = puzzle.dot(r, c)
          right = puzzle.dot(r, c+1)
          if right
            assert_equal 1, dot.lines.select { |line| line.dot2 == right }.length
          end
          below = puzzle.dot(r+1, c)
          if below
            assert_equal 1, dot.lines.select { |line| line.dot2 == below }.length
          end
        end
      end
    end

    def assert_has_fixed_lines(puzzle, *lines)
      lines.each do |dot1, dot2|
        line = puzzle.lines.select do |line|
          line.dot1.row == dot1[0] && line.dot1.col == dot1[1] && line.dot2.row == dot2[0] && line.dot2.col == dot2[1]
        end.first
        assert line.fixed?, "Line #{dot1.inspect},#{dot2.inspect} should be fixed."
      end
      assert_equal lines.length, puzzle.lines.select(&:fixed?).length
    end
  end
end
