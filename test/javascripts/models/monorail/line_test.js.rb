require 'models/monorail/line'

module Monorail
  class LineTest < Minitest::Test
    test 'observable' do
      assert_kind_of Vienna::Observable, Line.new
    end

    test 'attributes' do
      assert_equal %i(dot1 dot2 present?), Line.columns
    end
  end
end
