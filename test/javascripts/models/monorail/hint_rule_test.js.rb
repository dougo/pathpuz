require 'models/pathpuz/monorail/hint_rule'

module Monorail
  class HintRuleTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(disabled), HintRule.columns
    end

    test 'Observable' do
      assert_kind_of Vienna::Observable, HintRule.new
    end

    test 'applicable?' do
      puzzle = Puzzle.of_size(2)
      subject = HintRule.new
      assert subject.applicable?(puzzle)
      puzzle.lines.each &:next_state!
      refute subject.applicable?(puzzle)
    end

    test 'apply' do
      puzzle = Puzzle.of_size(2)
      subject = HintRule.new
      subject.apply(puzzle)
      assert_equal 2, puzzle.dots.first.present_lines.length

      puzzle.lines.each { |l| l.state = :present }
      subject.apply(puzzle) # does nothing, but test that it doesn't raise an error
    end

    test 'not applicable when disabled' do
      puzzle = Puzzle.of_size(2)
      subject = HintRule.new(disabled: true)
      refute subject.applicable?(puzzle)
      subject.apply(puzzle)
      assert puzzle.dots.first.completable?
    end
  end
end
