require 'models/pathpuz/monorail/line'

module Monorail
  class LineTest < Minitest::Test
    test 'observable' do
      assert_kind_of Vienna::Observable, Line.new
    end

    test 'attributes' do
      assert_equal %i(dot1 dot2 state), Line.columns
    end

    test 'present?' do
      refute Line.new.present?
      assert Line.new(state: :present).present?
      assert Line.new(state: :fixed).present?
      refute Line.new(state: :absent).present?
    end

    test 'fixed?' do
      refute Line.new.fixed?
      refute Line.new(state: :present).fixed?
      assert Line.new(state: :fixed).fixed?
      refute Line.new(state: :absent).fixed?
    end

    test 'absent?' do
      refute Line.new.absent?
      refute Line.new(state: :present).absent?
      refute Line.new(state: :fixed).absent?
      assert Line.new(state: :absent).absent?
    end

    test 'add to dots' do
      dot1 = Dot.new
      dot2 = Dot.new
      subject = Line.new(dot1: dot1, dot2: dot2)
      assert_equal [subject], dot1.lines
      assert_equal [subject], dot2.lines
    end

    test 'other_dot' do
      dot1 = Dot.new
      dot2 = Dot.new
      subject = Line.new(dot1: dot1, dot2: dot2)
      assert_equal dot2, subject.other_dot(dot1)
      assert_equal dot1, subject.other_dot(dot2)
    end
  end
end
