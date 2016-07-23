require 'models/pathpuz/monorail/hint_rule'

module Monorail
  class HintRuleTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(type disabled), HintRule.columns
    end

    test 'Observable' do
      assert_kind_of Vienna::Observable, HintRule.new
    end

    test 'unknown type is not applicable' do
      puzzle = Puzzle.of_size(2)
      subject = HintRule.new(type: :foobar)
      refute subject.applicable?(puzzle)
      subject.apply(puzzle)
      assert_empty puzzle.lines.select(&:present?)
    end

    test 'applicable? for every_dot_has_two_lines' do
      puzzle = Puzzle.of_size(2)
      subject = HintRule.new(type: :every_dot_has_two_lines)
      assert subject.applicable?(puzzle)
      puzzle.lines.each &:next_state!
      refute subject.applicable?(puzzle)
    end

    test 'applicable? for every_dot_has_only_two_lines' do
      puzzle = Puzzle.of_size(3)
      subject = HintRule.new(type: :every_dot_has_only_two_lines)
      refute subject.applicable?(puzzle)
      dot = puzzle.dots.find { |dot| dot.lines.length > 2 }
      dot.lines.first.next_state!
      dot.lines.last.next_state!
      assert subject.applicable?(puzzle)
    end

    test 'apply for every_dot_has_two_lines' do
      puzzle = Puzzle.of_size(2)
      subject = HintRule.new(type: :every_dot_has_two_lines)
      subject.apply(puzzle)
      assert_equal 2, puzzle.dots.first.present_lines.length

      puzzle.lines.each { |l| l.state = :present }
      subject.apply(puzzle) # does nothing, but test that it doesn't raise an error
    end

    test 'apply for every_dot_has_only_two_lines' do
      puzzle = Puzzle.of_size(3)
      subject = HintRule.new(type: :every_dot_has_only_two_lines)
      dot = puzzle.dots.find { |dot| dot.lines.length > 2 }
      dot.lines.first.next_state!
      dot.lines.last.next_state!
      subject.apply(puzzle)
      assert_empty dot.unknown_lines
    end

    test 'not applicable when disabled' do
      puzzle = Puzzle.of_size(2)
      subject = HintRule.new(type: :every_dot_has_two_lines, disabled: true)
      refute subject.applicable?(puzzle)
      subject.apply(puzzle)
      assert puzzle.dots.first.completable?
    end
  end
end
