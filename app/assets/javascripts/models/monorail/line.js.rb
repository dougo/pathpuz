require 'vienna'
require 'vienna/observable'

module Monorail
  class Line < Vienna::Model
    include Vienna::Observable

    attributes :dot1, :dot2, :present?

    def initialize(attrs = nil)
      super
      dot1.lines << self if dot1
      dot2.lines << self if dot2
    end
  end
end
