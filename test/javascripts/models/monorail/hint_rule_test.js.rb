require 'models/pathpuz/monorail/hint_rule'

module Monorail
  class HintRuleTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(type auto), HintRule.columns
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

    test 'short_loop_line type' do
      puzzle = Puzzle.of_size(3)
      subject = HintRule.new(type: :short_loop_line)
      refute subject.applicable?(puzzle)
      puzzle.dot(0,0).complete!
      puzzle.dot(0,2).complete!
      puzzle.dot(0,1).complete!
      puzzle.dot(1,2).complete!
      # Puzzle now looks like this:
      # o---o---o
      # |   x   |
      # o   o---o
      #
      # o   o
      assert subject.applicable?(puzzle)

      event = false
      puzzle.on(:lines_changed) { event = true }
      subject.apply(puzzle)
      assert event
      assert_predicate puzzle.line(1,0, 1,1), :absent?

      puzzle.dot(2,0).complete!
      # Now the loop could be closed, since it touches every dot:
      # o---o---o
      # |   x   |
      # o x o---o
      # |   
      # o---o
      refute subject.applicable?(puzzle)
    end

    test 'short_loop_dot type' do
      puzzle = Puzzle.of_size(3)
      subject = HintRule.new(type: :short_loop_dot)
      refute subject.applicable?(puzzle)
      puzzle.line(0,0, 1,0).mark_present!
      puzzle.dot(2,0).complete!
      puzzle.dot(2,1).complete!
      # Puzzle now looks like this:
      # o   o   o
      # |        
      # o   o   o
      # |   |
      # o---o
      # Two of the three lines at 0,1 must be present, but connecting 0,0 and 1,1 would be a short loop.
      # Thus 0,1--0,2 must be present.
      assert subject.applicable?(puzzle)
      subject.apply(puzzle)
      assert_predicate puzzle.line(0,1, 0,2), :present?

      puzzle.undo!
      puzzle.dot(0,1).lines.rotate! # order shouldn't matter...
      subject.apply(puzzle)
      assert_predicate puzzle.line(0,1, 0,2), :present?

      puzzle.undo!
      puzzle.dot(0,1).lines.rotate! # one more time!
      subject.apply(puzzle)
      assert_predicate puzzle.line(0,1, 0,2), :present?

      puzzle.line(0,2, 1,2).mark_present!
      # Puzzle now looks like this:
      # o   o---o
      # |       |
      # o   o   o
      # |   |
      # o---o
      # The hint rule should not apply to 1,1, because it doesn't need two lines (it already has one).
      refute subject.applicable?(puzzle)
    end
  end
end
