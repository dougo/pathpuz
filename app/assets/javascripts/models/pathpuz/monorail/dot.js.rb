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

    def complete!
      unknown_lines = lines.select(&:unknown?)
      if unknown_lines.length + present_lines.length <= 2
        unknown_lines.each { |l| l.state = :present }
      end
    end
  end
end
