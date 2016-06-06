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

    test 'present_lines' do
      subject.lines << Line.new
      assert_equal [], subject.present_lines

      line = Line.new(state: :present)
      subject.lines << line
      assert_equal [line], subject.present_lines
    end

    test 'complete! with two unknown lines makes them present' do
      subject.lines << Line.new << Line.new
      subject.complete!
      assert subject.lines[0].present?
      assert subject.lines[1].present?
    end

    test 'complete! with three unknown lines does nothing' do
      subject.lines << Line.new << Line.new << Line.new
      subject.complete!
      assert subject.lines[0].unknown?
      assert subject.lines[1].unknown?
      assert subject.lines[2].unknown?
    end

    test 'complete! with two unknown lines and one present does nothing' do
      subject.lines << Line.new << Line.new << Line.new(state: :present)
      subject.complete!
      assert subject.lines[0].unknown?
      assert subject.lines[1].unknown?
      assert subject.lines[2].present?
    end

    test 'complete! with one unknown line and one present makes the unknown present' do
      subject.lines << Line.new << Line.new(state: :present)
      subject.complete!
      assert subject.lines[0].present?
      assert subject.lines[1].present?
    end

    test 'complete! with two unknown lines and one absent makes the unknown present' do
      subject.lines << Line.new << Line.new << Line.new(state: :absent)
      subject.complete!
      assert subject.lines[0].present?
      assert subject.lines[1].present?
      assert subject.lines[2].absent?
    end

    private

    def subject
      @subject ||= Dot.new
    end
  end
end
