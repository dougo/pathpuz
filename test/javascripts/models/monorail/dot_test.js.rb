require 'models/monorail/dot'

module Monorail
  class DotTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(row col), Dot.columns
    end
  end
end
