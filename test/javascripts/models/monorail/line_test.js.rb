require 'models/monorail/line'

module Monorail
  class LineTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(present?), Line.columns
    end
  end
end
