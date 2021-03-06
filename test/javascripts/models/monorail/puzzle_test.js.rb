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
      lines = [[[0,2],[1,2]], [[1,1],[2,1]], [[1,4],[2,4]], [[3,2],[3,3]], [[3,3],[4,3]], [[3,5],[4,5]], [[4,2],[5,2]]]
      assert_has_fixed_lines(subject, *lines)
    end

    test 'puzzle 6' do
      subject = Puzzle.find(6)
      assert_equal 6, subject.id
      assert_has_grid_of_dots(subject, 7, [3,3])
      assert_nil subject.dot(3,3)
      assert_dot(subject, 6,6)
      assert_adjacent_dots_are_connected(subject)
      assert_equal 2*36 + 2*6 - 4, subject.lines.length
      lines = [[[1,5],[1,6]], [[2,1],[2,2]], [[3,1],[3,2]], [[4,0],[4,1]], [[5,3],[5,4]], [[5,3],[6,3]], [[5,5],[5,6]]]
      assert_has_fixed_lines(subject, *lines)
    end

    test 'puzzle 7' do
      subject = Puzzle.find(7)
      assert_equal 7, subject.id
      assert_square_of_size(subject, 8)
      lines = [[[0,4],[1,4]], [[2,1],[2,2]], [[2,2],[3,2]], [[2,5],[2,6]], [[3,2],[4,2]], [[3,5],[4,5]], [[3,7],[4,7]],
               [[4,2],[4,3]], [[4,5],[4,6]], [[5,0],[5,1]], [[5,4],[6,4]], [[6,3],[6,4]], [[6,3],[7,3]], [[7,5],[7,6]]]
      assert_has_fixed_lines(subject, *lines)
    end

    test 'puzzle 8' do
      subject = Puzzle.find(8)
      assert_equal 8, subject.id
      assert_square_of_size(subject, 12)
      lines = [[[0,4],[0,5]], [[0,5],[0,6]], [[0,7],[1,7]],
               [[1,0],[2,0]], [[1,1],[2,1]], [[1,2],[2,2]], [[1,3],[1,4]], [[1,7],[1,8]], [[1,10],[2,10]],
               [[2,1],[2,2]], [[2,4],[3,4]], [[2,7],[3,7]], [[2,9],[2,10]],
               [[3,1],[4,1]], [[3,3],[3,4]], [[3,5],[4,5]], [[3,6],[4,6]], [[3,8],[3,9]], [[3,10],[4,10]],
               [[4,0],[5,0]], [[4,2],[4,3]], [[4,3],[5,3]], [[4,6],[5,6]], [[4,9],[4,10]],
               [[5,4],[6,4]], [[5,7],[5,8]], [[5,9],[6,9]],
               [[6,0],[6,1]], [[6,1],[6,2]], [[6,2],[7,2]], [[6,8],[6,9]], [[6,8],[7,8]],
               [[7,1],[8,1]], [[7,3],[8,3]],
               [[8,2],[9,2]], [[8,3],[9,3]], [[8,5],[8,6]], [[8,6],[9,6]], [[8,8],[8,9]],
               [[9,4],[9,5]], [[9,6],[9,7]], [[9,10],[9,11]],
               [[10,1],[11,1]], [[10,4],[11,4]], [[10,7],[11,7]], [[10,8],[11,8]], [[10,10],[11,10]],
               [[11,6],[11,7]], [[11,8],[11,9]]]
      assert_has_fixed_lines(subject, *lines)
    end

    test 'puzzle 9' do
      subject = Puzzle.find(9)
      assert_equal 9, subject.id
      dots = [       [0,1],[0,2],[0,3],
              [1,0.5],[1,1.5],[1,2.5],[1,3.5],
               [2,0],[2,1],[2,2],[2,3],[2,4],
              [3,0.5],[3,1.5],[3,2.5],[3,3.5],
                     [4,1],[4,2],[4,3]]
      dots.each do |r,c|
        assert_dot(subject, r,c)
        dot = subject.dot(r, c)
        right = subject.dot(r, c+1)
        if right
          msg = "#{dot.inspect} should connect to #{right.inspect}"
          assert_equal 1, dot.lines.select { |line| line.dot2 == right }.length, msg
        end
        below_left = subject.dot(r+1, c-0.5)
        if below_left
          msg = "#{dot.inspect} should connect to #{below_left.inspect}"
          assert_equal 1, dot.lines.select { |line| line.dot2 == below_left }.length, msg
        end
        below_right = subject.dot(r+1, c+0.5)
        if below_right
          msg = "#{dot.inspect} should connect to #{below_right.inspect}"
          assert_equal 1, dot.lines.select { |line| line.dot2 == below_right }.length, msg
        end
      end
      assert_equal 14*3, subject.lines.length

      lines = [[[1,0.5],[2,1]], [[1,1.5],[1,2.5]], [[2,2],[2,3]], [[2,3],[2,4]], [[3,1.5],[3,2.5]], [[3,2.5],[4,2]]]
      assert_has_fixed_lines(subject, *lines)
    end

    test 'count' do
      assert_equal 10, Puzzle.count
    end

    test 'find returns nil for nonexistent puzzle' do
      assert_nil Puzzle.find(Puzzle.count)
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

    test 'line' do
      subject = Puzzle.of_size(2)
      line = subject.line(0,0, 0,1)
      assert_equal subject.dot(0,0), line.dot1
      assert_equal subject.dot(0,1), line.dot2

      line = subject.line(1,1, 1,0)
      assert_equal subject.dot(1,0), line.dot1
      assert_equal subject.dot(1,1), line.dot2

      assert_nil subject.line(0,0, 1,1)
      assert_nil subject.line(2,2, 1,1)
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

    test 'can_undo?' do
      subject = Puzzle.of_size(2)
      refute subject.can_undo?
      subject.lines.first.next_state!
      assert subject.can_undo?
    end

    test 'undo! line state change' do
      subject = Puzzle.of_size(2)
      line = subject.lines.first
      line.next_state!
      subject.undo!
      assert line.unknown?
      refute subject.can_undo?
    end

    test 'undo! a complete dot' do
      subject = Puzzle.of_size(2)
      subject.dots.first.complete!
      subject.undo!
      assert subject.dots.first.lines.first.unknown?
      assert subject.dots.first.lines.last.unknown?
      refute subject.can_undo?
    end

    test 'undo! absent lines via dot completion' do
      subject = Puzzle.of_size(3)
      subject.dots[0].complete!
      subject.dots[2].complete!
      subject.dots[1].complete!
      line = subject.lines.find &:absent?
      subject.undo!
      assert line.unknown?
    end

    %i(undo! reset!).each do |action|
      test "undone event on #{action}" do
        subject = Puzzle.of_size(2)
        subject.lines.first.next_state!
        undone = false
        subject.on(:undone) { undone = true }
        subject.send(action)
        assert undone
      end
    end

    test 'reset!' do
      subject = Puzzle.of_size(2)
      subject.lines.each &:next_state!
      subject.lines.first.state = :fixed
      subject.reset!
      assert_equal 3, subject.lines.select(&:unknown?).length
      assert_predicate subject.lines.first, :fixed?
      refute subject.can_undo?
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

    test 'lines_changed event when line goes to next state' do
      subject = Puzzle.of_size(2)
      changes = nil
      subject.on(:lines_changed) { |*ch| changes = ch }
      line = subject.lines.first
      line.next_state!
      assert_equal [line], changes.map(&:line)
      assert_equal [nil], changes.map(&:prev_state)

      subject.undo!
      line.state = :present
      line.next_state!
      assert_equal [:present], changes.map(&:prev_state)
    end

    test 'lines_changed event when dot completed' do
      subject = Puzzle.of_size(2)
      changes = nil
      subject.on(:lines_changed) { |*ch| changes = ch }
      dot = subject.dots.first
      dot.complete!
      assert_equal dot.lines, changes.map(&:line)
      assert_equal [nil, nil], changes.map(&:prev_state)
    end

    test 'with_changes_combined combines history' do
      subject = Puzzle.of_size(2)
      subject.dots.first.complete!
      subject.with_changes_combined { subject.dots.last.complete! }
      assert subject.solved?
      subject.undo!
      assert subject.lines.none?(&:present?)
    end

    test 'changing the same line twice undoes first combined changes' do
      subject = Puzzle.of_size(2)
      line = subject.lines.first
      line.next_state!
      subject.with_changes_combined { subject.dots.first.complete! }
      line.next_state!
      assert line.absent?
      assert subject.lines.none?(&:present?)
      subject.undo!
      assert subject.lines.all?(&:unknown?)
    end

    test 'cycling a line through all states is a no-op' do
      subject = Puzzle.of_size(2)
      line = subject.lines.first
      3.times { line.next_state! }
      refute subject.can_undo?
    end

    private

    def assert_square_of_size(puzzle, size)
      assert_has_grid_of_dots(puzzle, size)
      assert_bottom_right_dot_is_omitted(puzzle, size) if size.odd?
      assert_has_expected_num_lines(puzzle, size)
      assert_adjacent_dots_are_connected(puzzle)
    end

    def assert_has_grid_of_dots(puzzle, size, except = nil)
      (0...size).each do |r|
        (0...size).each do |c|
          next if size.odd? && r == size-1 && c == size-1
          if except
            except_r, except_c = except
            next if r == except_r && c == except_c
          end
          assert_dot(puzzle, r, c)
        end
      end
    end

    def assert_dot(puzzle, r, c)
      dot = puzzle.dot(r, c)
      assert_kind_of Dot, dot
      assert_equal r, dot.row
      assert_equal c, dot.col
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
          next unless dot
          right = puzzle.dot(r, c+1)
          if right
            msg = "#{dot.inspect} should connect to #{right.inspect}"
            assert_equal 1, dot.lines.select { |line| line.dot2 == right }.length, msg
          end
          below = puzzle.dot(r+1, c)
          if below
            msg = "#{dot.inspect} should connect to #{below.inspect}"
            assert_equal 1, dot.lines.select { |line| line.dot2 == below }.length, msg
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

    def print_lines(puzzle)
      puts
      puzzle.lines.each do |l|
        st = l.fixed? ? ', state: :fixed' : ''
        puts "{dot1: {row: #{l.dot1.row}, col: #{l.dot1.col}}, dot2: {row: #{l.dot2.row}, col: #{l.dot2.col}}#{st}},"
      end
    end
  end
end
