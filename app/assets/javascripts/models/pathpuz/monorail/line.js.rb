require 'vienna'
require 'vienna/observable'

module Monorail
  class Line < Vienna::Model
    include Vienna::Observable

    attributes :dot1, :dot2, :state

    def initialize(attrs = nil)
      super
      dot1.lines << self if dot1
      dot2.lines << self if dot2
    end

    def present?
      state == :present || state == :fixed
    end

    def fixed?
      state == :fixed
    end

    def absent?
      state == :absent
    end

    def unknown?
      state == nil
    end

    def other_dot(dot)
      dot == dot1 ? dot2 : dot1
    end

    def next_state
      case state
      when nil
        :present
      when :present
        :absent
      end
    end

    def next_state!
      change_state! next_state
    end

    def mark_present!
      change_state! :present
    end

    def mark_absent!
      change_state! :absent
    end

    private

    def change_state!(new_state)
      prev_state = state
      self.state = new_state
      trigger(:state_changed, prev_state)
    end
  end
end
