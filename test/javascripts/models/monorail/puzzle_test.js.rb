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
  end
end
