require 'vienna'

module Monorail
  class Line < Vienna::Model
    attributes :dot1, :dot2, :present?
  end
end
