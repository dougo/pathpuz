require 'vienna'

module Monorail
  class Puzzle < Vienna::Model
    attributes :dots, :lines

    def initialize(size = 2)
      maxrow = size - 1
      self.dots = (0..maxrow).map do |row|
        maxcol = size - 1
        if size.odd?
          # To make an even number of dots total, omit the last dot of the last row.
          maxcol -= 1 if row == maxrow
        end
        (0..maxcol).map do |col|
          Dot.new(row: row, col: col)
        end
      end

      self.lines = []
      (0...dots.length).each do |r|
        row = dots[r]
        (0...row.length).each do |c|
          lines << connect(dots[r][c], dots[r][c+1]) unless c+1 == row.length
          lines << connect(dots[r][c], dots[r+1][c]) unless r+1 == dots.length || c == dots[r+1].length
        end
      end

      lines.each do |line|
        line.add_observer(:present?) do
          trigger(:solved) if solved?
        end
      end
    end

    def height
      dots.length
    end

    def width
      dots.first.length
    end

    def solved?
      lines.all? &:present?
    end

    private

    def connect(dot1, dot2)
      Line.new(dot1: dot1, dot2: dot2)
    end
  end
end
