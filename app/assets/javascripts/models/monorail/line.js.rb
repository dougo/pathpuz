require 'vienna'
require 'vienna/observable'

module Monorail
  class Line < Vienna::Model
    include Vienna::Observable

    attributes :dot1, :dot2, :present?
  end
end
