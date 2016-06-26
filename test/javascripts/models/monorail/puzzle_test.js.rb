require 'models/pathpuz/monorail/puzzle'

module Monorail
  class PuzzleTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(lines), Puzzle.columns
    end

    test 'lines= creates models and adds observers' do
      subject = Puzzle.new
      subject.lines = [{dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                       {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                       {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}, state: :present},
                       {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}}]
      assert_has_grid_of_dots subject, 2
      assert_equal 4, subject.lines.length
      assert_adjacent_dots_are_connected subject
      assert_equal :present, subject.lines[2].state

      event = false
      subject.on(:solved) { event = true }
      subject.lines[0].state = :present
      subject.lines[1].state = :present
      subject.lines[3].state = :present
      assert event
    end

    test 'size 2' do
      subject = Puzzle.of_size(2)
      assert_has_grid_of_dots subject, 2
      assert_equal 4, subject.lines.length
      assert_adjacent_dots_are_connected subject
    end

    test 'size 3' do
      subject = Puzzle.of_size(3)
      assert_bottom_right_dot_is_omitted subject, 3
      assert_equal 10, subject.lines.length
      assert_adjacent_dots_are_connected subject
    end

    test 'size 4' do
      subject = Puzzle.of_size(4)
      assert_has_grid_of_dots subject, 4
      assert_equal 24, subject.lines.length
      assert_adjacent_dots_are_connected subject
      [2, 12, 16].each do |i|
        assert subject.lines[i].present?, "Line #{i} should be present."
        assert subject.lines[i].fixed?,   "Line #{i} should be fixed."
      end
    end

    test 'size 5' do
      subject = Puzzle.of_size(5)
      assert_bottom_right_dot_is_omitted subject, 5
      assert_equal 38, subject.lines.length
      assert_adjacent_dots_are_connected subject
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
      event = nil
      subject.on(:solved) { event = true }
      (0..2).each { |i| subject.lines[i].state = :present }
      refute subject.solved?
      refute event
      subject.lines[3].state = :present
      assert subject.solved?
      assert event
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

    private

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
  end
end
