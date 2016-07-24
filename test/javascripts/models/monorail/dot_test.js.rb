require 'models/pathpuz/monorail/dot'

module Monorail
  class DotTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(row col), Dot.columns
    end

    test 'lines' do
      assert_equal [], subject.lines
      line = Line.new
      subject.lines << line
      assert_equal [line], subject.lines
    end

    test 'unknown_lines' do
      subject.lines << Line.new(state: :present) << Line.new(state: :absent)
      assert_equal [], subject.unknown_lines

      line = Line.new
      subject.lines << line
      assert_equal [line], subject.unknown_lines
    end

    test 'present_lines' do
      subject.lines << Line.new
      assert_equal [], subject.present_lines

      line = Line.new(state: :present)
      subject.lines << line
      assert_equal [line], subject.present_lines
    end

    test 'completable? with two unknown lines is :present' do
      subject.lines << Line.new << Line.new
      assert_equal :present, subject.completable?
    end

    test 'completable? with three unknown lines is false' do
      subject.lines << Line.new << Line.new << Line.new
      refute subject.completable?
    end

    test 'completable? with two unknown lines and one present is false' do
      subject.lines << Line.new << Line.new << Line.new(state: :present)
      refute subject.completable?
    end

    test 'completable? with one unknown line and one present is :present' do
      subject.lines << Line.new << Line.new(state: :present)
      assert_equal :present, subject.completable?
    end

    test 'completable? with two unknown lines and one absent is :present' do
      subject.lines << Line.new << Line.new << Line.new(state: :absent)
      assert_equal :present, subject.completable?
    end

    test 'completable? with two present lines is :absent' do
      subject.lines << Line.new << Line.new(state: :present) << Line.new << Line.new(state: :present)
      assert_equal :absent, subject.completable?
    end

    test 'completable? with two present lines and no unknown lines is false' do
      subject.lines << Line.new(state: :present) << Line.new(state: :present)
      refute subject.completable?
    end

    test 'complete! makes unknown lines present' do
      subject.lines << Line.new << Line.new(state: :absent) << Line.new
      subject.complete!
      assert subject.lines[0].present?
      assert subject.lines[1].absent?
      assert subject.lines[2].present?
    end

    test 'complete! makes unknown lines absent' do
      subject.lines << Line.new << Line.new(state: :present) << Line.new << Line.new(state: :present)
      subject.complete!
      assert subject.lines[0].absent?
      assert subject.lines[1].present?
      assert subject.lines[2].absent?
      assert subject.lines[3].present?
    end

    test 'complete! leaves unknown lines unknown' do
      subject.lines << Line.new << Line.new << Line.new(state: :present)
      subject.complete!
      assert subject.lines[0].unknown?
      assert subject.lines[1].unknown?
      assert subject.lines[2].present?
    end

    test 'completed event' do
      subject.lines << Line.new << Line.new
      completed_args = nil
      subject.on(:completed) { |*args| completed_args = args }
      subject.complete!
      assert_equal [:present, *subject.lines], completed_args
    end

    test 'no completed event if not completable' do
      subject.on(:completed) { flunk }
      subject.complete!
    end

    test 'connected_dots' do
      dots = [subject, Dot.new, Dot.new, Dot.new, Dot.new]
      Line.new(dot1: subject, dot2: dots[1], state: :present)
      Line.new(dot1: subject, dot2: Dot.new)
      Line.new(dot1: subject, dot2: dots[2], state: :fixed)
      Line.new(dot1: dots[2], dot2: dots[3], state: :present)
      Line.new(dot1: dots[4], dot2: dots[3], state: :present)
      assert_equal Set.new(dots), subject.connected_dots
    end

    private

    def subject
      @subject ||= Dot.new
    end
  end
end
