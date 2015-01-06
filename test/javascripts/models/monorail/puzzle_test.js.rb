require 'models/monorail/puzzle'

module Monorail
  class PuzzleTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(dots lines), Puzzle.columns
    end

    test 'dots form a grid' do
      dots = Puzzle.new.dots
      assert_equal 2, dots.length
      dots.each_with_index do |row, r|
        assert_equal 2, row.length
        row.each_with_index do |dot, c|
          assert_equal r, dot[:row]
          assert_equal c, dot[:col]
        end
      end
    end

    test 'lines form a lattice' do
      lines = Puzzle.new.lines
      assert_equal 4, lines.length
      assert_equal 2, lines.select { |line| line.dot1[:row] == line.dot2[:row] }.length
      assert_equal 2, lines.select { |line| line.dot1[:col] == line.dot2[:col] }.length
      assert_equal 2, lines.select { |line| line.dot1[:row] == 0 && line.dot1[:col] == 0 }.length
      assert_equal 2, lines.select { |line| line.dot2[:row] == 1 && line.dot2[:col] == 1 }.length
    end
  end
end
