require 'vienna'

module Monorail
  class Dot < Vienna::Model
    attributes :row, :col

    attr_reader :lines

    def initialize(attrs)
      super
      @lines = []
    end

    def present_lines
      lines.select(&:present?)
    end

    # Since each dot must have exactly two lines present, sometimes we can mark the remaining unknown lines.
    def complete!
      unknown = lines.select(&:unknown?)
      present = present_lines
      if present.length == 2
        # The route is already determined for this dot; mark the other lines as absent.
        unknown.each { |l| l.state = :absent }
      elsif unknown.length + present.length <= 2
        # There's at most 2 possible lines remaining; mark them as present.
        unknown.each { |l| l.state = :present }
      end
    end
  end
end
