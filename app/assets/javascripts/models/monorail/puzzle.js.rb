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

      self.lines = [connect(dots[0][0], dots[0][1]),
                    connect(dots[0][0], dots[1][0]),
                    connect(dots[0][1], dots[1][1]),
                    connect(dots[1][0], dots[1][1])]
    end

    private

    def connect(dot1, dot2)
      Line.new(dot1: dot1, dot2: dot2)
    end
  end
end
