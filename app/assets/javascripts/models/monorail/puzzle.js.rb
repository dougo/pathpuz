require 'vienna'

module Monorail
  class Puzzle < Vienna::Model
    attributes :dot_rows, :lines

    def initialize(size = 2)
      maxrow = size - 1
      self.dot_rows = (0..maxrow).map do |row|
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
      (0...height).each do |r|
        row = dot_rows[r]
        (0...row.length).each do |c|
          connect(dot(r, c), dot(r, c+1)) unless c+1 == row.length
          connect(dot(r, c), dot(r+1, c)) unless r+1 == height || c == dot_rows[r+1].length
        end
      end

      lines.each do |line|
        line.add_observer(:present?) do
          trigger(:solved) if solved?
        end
      end
    end

    def connect(dot1, dot2)
      lines << Line.new(dot1: dot1, dot2: dot2)
    end

    def dot(r, c)
      dot_rows[r][c]
    end

    def dots
      dot_rows.flatten
    end

    def height
      dot_rows.length
    end

    def width
      dot_rows.first.length
    end

    # Is there a single looping path that visits every dot?
    def solved?
      first_dot = dot(0, 0)
      dot = first_dot
      num_dots_visited = 1
      line = dot.present_lines.first
      return false unless line
      loop do
        # Follow the line.
        dot = line.other_dot(dot)
        if dot == first_dot
          # We've made a complete loop; has every dot been visited?
          return num_dots_visited == dots.length
        end
        num_dots_visited += 1

        # Find the next line to follow.
        lines = dot.present_lines - [line]
        unless lines.length == 1
          # If there's not exactly one line to follow, the path either ends or branches.
          return false
        end
        line = lines.first
      end
    end
  end
end
