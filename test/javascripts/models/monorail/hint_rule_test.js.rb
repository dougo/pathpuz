require 'models/pathpuz/monorail/hint_rule'

module Monorail
  class HintRuleTest < Minitest::Test
    test 'attributes' do
      assert_equal %i(disabled), HintRule.columns
    end

    test 'Observable' do
      assert_kind_of Vienna::Observable, HintRule.new
    end
  end
end
