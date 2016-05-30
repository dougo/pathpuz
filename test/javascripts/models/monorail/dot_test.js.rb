require 'models/pathpuz/monorail/dot'

module Monorail
  class DotTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(row col), Dot.columns
    end

    test 'lines' do
      subject = Dot.new
      assert_equal [], subject.lines
      line = Line.new
      subject.lines << line
      assert_equal [line], subject.lines
    end

    test 'present_lines' do
      subject = Dot.new
      subject.lines << Line.new
      assert_equal [], subject.present_lines

      line = Line.new(:present? => true)
      subject.lines << line
      assert_equal [line], subject.present_lines
    end
  end
end
