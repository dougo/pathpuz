require 'vienna'

module Monorail
  class Puzzle < Vienna::Model
    attributes :dots, :lines

    def initialize
      self.dots = (0..1).map do |row|
        (0..1).map do |col|
          Dot.new(row: row, col: col)
        end
      end
    end
  end
end
