require 'models/monorail/line'

module Monorail
  class LineTest < Minitest::Test
    test 'observable' do
      assert_kind_of Vienna::Observable, Line.new
    end

    test 'attributes' do
      assert_equal %i(dot1 dot2 present?), Line.columns
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
