require 'models/monorail/dot'

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
  end
end
