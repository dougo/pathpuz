require 'vienna'

module Monorail
  class HintRule < Vienna::Model
    include Vienna::Observable

    attribute :disabled
  end
end
