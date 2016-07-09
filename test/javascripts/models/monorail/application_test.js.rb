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
    end
  end
end
