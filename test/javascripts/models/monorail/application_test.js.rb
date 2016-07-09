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

    test 'next_puzzle!' do
      subject = Application.new
      subject.next_puzzle!
      subject.router.update # TODO: shouldn't the hashchange event do this?
      assert_equal 1, subject.puzzle.id
      assert_equal "#1", $global.location.hash
    end

    test 'return to old puzzle on back button' do
      subject = Application.new
      subject.next_puzzle!
      subject.router.update
      # `history.back()` # TODO: why doesn't this work?
      $global.location.hash = ''
      subject.router.update
      assert_equal 0, subject.puzzle.id
    end

    test 'auto-hint behavior' do
      subject = Application.new
      events = []
      puzzle = Puzzle.of_size(2) # don't use Puzzle.find(0) because modifying it will mess up other tests
      puzzle.on(:lines_changed) { |*args| events << args }
      subject.puzzle = puzzle
      subject.autohint = true
      assert_equal [puzzle.dots.first.lines, [puzzle.lines[2]], [puzzle.lines[3]]], events
    end

    test 'auto-hint when puzzle changes' do
      subject = Application.new(autohint: true)
      subject.puzzle = Puzzle.of_size(3)
      assert_predicate subject.puzzle, :solved?
    end
  end
end
