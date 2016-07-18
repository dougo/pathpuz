require 'models/pathpuz/monorail/application'

module Monorail
  class ApplicationTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(router puzzle autohint), Application.columns
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
