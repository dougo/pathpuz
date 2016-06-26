require 'vienna'

module Monorail
  class Puzzle < Vienna::Model
    attributes :dot_rows, :lines

    def self.of_size(size)
      new.make!(size)
    end

    def lines=(lines)
      @lines = lines.map do |line|
        dot1 = line[:dot1]
        dot2 = line[:dot2]
        Line.new(dot1: dot(dot1[:row], dot1[:col]), dot2: dot(dot2[:row], dot2[:col]), state: line[:state])
      end

      @lines.each do |line|
        line.add_observer(:state) do
          trigger(:solved) if solved?
        end
      end

      @lines
    end

    def attributes=(attrs)
      self.dot_rows = attrs[:dot_rows].map do |dot_row|
        dot_row.map do |dot|
          Dot.new(row: dot[:row], col: dot[:col])
        end
      end

      self.lines = attrs[:lines]
    end

    private

    def make!(size)
      self.attributes = self.class.json_for_size(size)
      self
    end

    def self.json_for_size(size = 2)
      maxrow = size - 1
      dot_rows = (0..maxrow).map do |row|
        maxcol = size - 1
        if size.odd?
          # To make an even number of dots total, omit the last dot of the last row.
          maxcol -= 1 if row == maxrow
        end
        (0..maxcol).map do |col|
          { row: row, col: col }
        end
      end

      lines = []
      (0...size).each do |r|
        row = dot_rows[r]
        (0...row.length).each do |c|
          lines << { dot1: { row: r, col: c }, dot2: { row: r, col: c+1 } } unless c+1 == row.length
          lines << { dot1: { row: r, col: c }, dot2: { row: r+1, col: c } } unless (r+1 == size ||
                                                                                    c == dot_rows[r+1].length)
        end
      end

      if size == 4
        # Add some fixed lines to make a unique solution.
        # TODO: load these from JSON...
        [2, 12, 16].each { |i| lines[i][:state] = :fixed }
      end

      { dot_rows: dot_rows, lines: lines }
    end

    public

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
      first_dot = dots.first
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
