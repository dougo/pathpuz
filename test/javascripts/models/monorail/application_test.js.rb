require 'models/pathpuz/monorail/application'

module Monorail
  class ApplicationTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(router puzzle autohint hint_rules), Application.columns
    end

    test 'Observable' do
      assert_kind_of Vienna::Observable, Application.new
    end

    test 'initialize' do
      subject = Application.new
      assert_kind_of Vienna::Router, subject.router
      assert_kind_of Puzzle, subject.puzzle
      assert_equal 0, subject.puzzle.id
      assert_equal false, subject.autohint
      assert_equal true, Application.new(autohint: true).autohint
    end

    test 'initialize with non-empty location hash' do
      $$.location.hash = '#2'
      subject = Application.new
      assert_equal 2, subject.puzzle.id
    end

    test 'next_puzzle!' do
      subject = Application.new
      subject.next_puzzle!

      # The hashchange event has been pushed onto the queue, but won't be handled until the test exits!
      # So we have to update the router ourselves.
      subject.router.update

      assert_equal 1, subject.puzzle.id
      assert_equal "#1", $$.location.hash
    end

    test 'prev_puzzle!' do
      subject = Application.new
      subject.puzzle = Puzzle.find(2)
      subject.prev_puzzle!; subject.router.update
      assert_equal 1, subject.puzzle.id
      assert_equal '#1', $$.location.hash

      subject.prev_puzzle!; subject.router.update
      assert_equal 0, subject.puzzle.id
      assert_empty $$.location.hash
    end

    test 'empty location hash goes to puzzle 0' do
      subject = Application.new
      subject.next_puzzle!; subject.router.update
      $$.location.hash = ''; subject.router.update
      assert_equal 0, subject.puzzle.id
    end

    test 'hint_rules' do
      subject = Application.new
      subject.hint_rules.each { |rule| assert_kind_of HintRule, rule }
      assert_equal %i(every_dot_has_two_lines every_dot_has_only_two_lines), subject.hint_rules.map(&:type)
    end

    test 'can_hint? if any hint rule is applicable' do
      subject = Application.new
      subject.puzzle = Puzzle.find(1)
      assert subject.can_hint?
      rule1, rule2 = subject.hint_rules
      rule1.apply(subject.puzzle) while rule1.applicable?(subject.puzzle)
      assert subject.can_hint?
      rule2.apply(subject.puzzle) while rule2.applicable?(subject.puzzle)
      refute subject.can_hint?
    end

    test 'hint! applies applicable hint rule' do
      subject = Application.new
      subject.puzzle = Puzzle.find(1)
      subject.hint!
      assert_equal 2, subject.puzzle.dots.first.present_lines.length
      rule = subject.hint_rules.first
      rule.apply(subject.puzzle) while rule.applicable?(subject.puzzle)
      subject.hint!
      refute_empty subject.puzzle.lines.select(&:absent?)
    end

    test 'auto-hint behavior' do
      events = []
      puzzle = Puzzle.find(0)
      puzzle.on(:lines_changed) { |*args| events << args }
      subject = Application.new(autohint: true)
      expected = [puzzle.dots.first.lines, [puzzle.lines[2]], [puzzle.lines[3]]]
      assert_equal expected, events.map { |changes| changes.map &:line }
      puzzle.undo!
      refute puzzle.can_undo?
    end

    test 'auto-hint when puzzle changes' do
      subject = Application.new(autohint: true)
      subject.next_puzzle!
      assert_predicate subject.puzzle, :solved?
    end
  end
end
