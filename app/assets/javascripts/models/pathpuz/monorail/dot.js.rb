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
  end
end
