require 'vienna'

module Monorail
  class Dot < Vienna::Model
    attributes :row, :col

    attr_reader :lines

    def initialize(attrs)
      super
      @lines = []
    end

    def unknown_lines
      lines.select(&:unknown?)
    end

    def present_lines
      lines.select(&:present?)
    end

    # Since each dot must have exactly two lines present, sometimes we know how to mark the remaining unknown lines.
    def completable?
      unknown = unknown_lines
      return false if unknown.empty?
      present = present_lines
      if present.length == 2
        # The route is already determined for this dot; the other lines must be absent.
        :absent
      elsif unknown.length + present.length <= 2
        # There's at most 2 possible lines remaining; they must be present.
        :present
      end
    end

    def complete!
      state = completable?
      if state
        unknown_lines.each { |l| l.state = state }
      end
    end
  end
end
