require 'vienna'

module Monorail
  class Puzzle < Vienna::Model
    attributes :lines

    def self.of_size(size)
      new(json_for_size(size))
    end

    def self.json_for_size(size = 2)
      lines = []
      (0...size).each do |r|
        (0...size).each do |c|
          # To make an even number of dots total, if size is odd, omit the last dot of the last row.
          unless c+1 == size || size.odd? && r == size-1 && c+1 == size-1
            lines << { dot1: { row: r, col: c }, dot2: { row: r, col: c+1 } }
          end
          unless r+1 == size || size.odd? && r+1 == size-1 && c == size-1
            lines << { dot1: { row: r, col: c }, dot2: { row: r+1, col: c } }
          end
        end
      end
      { lines: lines }
    end

    def self.count
      Adapter::PUZZLES.length
    end

    def initialize(*args)
      super
      @history ||= []
      on(:lines_changed) do |*changes|
        record_changes!(changes)
        trigger(:solved) if solved?
      end
    end

    class LineChange
      attr_accessor :line, :prev_state

      def initialize(line, prev_state = nil)
        @line, @prev_state = line, prev_state
      end
    end

    def lines=(lines)
      dots = lines.map { |l| l[:dot1] } + lines.map { |l| l[:dot2] }
      @dots = dots.uniq.map { |dot| [dot, Dot.new(dot)] }.to_h
      @lines = lines.map do |line|
        Line.new(dot1: @dots[line[:dot1]], dot2: @dots[line[:dot2]], state: line[:state])
      end

      @lines.each do |line|
        line.on(:state_changed) do |prev_state|
          trigger(:lines_changed, LineChange.new(line, prev_state))
        end
      end
      @dots.values.each do |dot|
        dot.on(:completed) do |state, *lines|
          trigger(:lines_changed, *lines.map { |line| LineChange.new(line) })
        end
      end

      @lines
    end

    def dot(r, c)
      @dots[{ row: r, col: c }]
    end

    def dots
      @dots.values
    end

    def line(r1,c1, r2,c2)
      dot1, dot2 = dot(r1,c1), dot(r2,c2)
      if dot1 && dot2
        dot1.lines.find { |line| line.other_dot(dot1) == dot2 }
      end
    end

    def height
      dots.map(&:row).max + 1
    end

    def width
      dots.map(&:col).max + 1
    end

    def can_undo?
      @history.any?
    end

    def undo!
      @history.pop.each { |change| change.line.state = change.prev_state }
      trigger(:undone)
    end

    def reset!
      lines.each { |l| l.state = nil unless l.fixed? }
      @history = []
      trigger(:undone)
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

    def with_changes_combined
      @combining_changes = true
      yield
      @combining_changes = false
    end

    private

    def record_changes!(changes)
      if can_undo? && @history.last.first.line == changes.first.line
        # If the same line changes multiple times in a row, treat it as a single change.
        changes.first.prev_state = @history.last.shift.prev_state
        undo!
        return if changes.first.line.state == changes.first.prev_state
      end
      if @combining_changes
        @history.push([]) if @history.empty?
        @history.last.push(*changes)
      else
        @history.push(changes)
      end
    end

    class Adapter < Vienna::Adapter
      def find(record, id, &block)
        return nil unless id < PUZZLES.length
        attrs = PUZZLES[id]
        model = record.class.load(attrs)
        block.call(model) if block
        model
      end

      PUZZLES =
        [
         {
           id: 0,
           lines: [
                   {dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                   {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}}
                  ]
         },
         {
           id: 1,
           lines: [
                   {dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                   {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 0, col: 2}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 2, col: 0}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 2, col: 1}}
                  ]
         },
         {
           id: 2,
           lines: [
                   {dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                   {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 0, col: 2}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 0, col: 3}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 2, col: 0}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 1, col: 2}, dot2: {row: 1, col: 3}, state: :fixed},
                   {dot1: {row: 1, col: 2}, dot2: {row: 2, col: 2}, state: :fixed},
                   {dot1: {row: 1, col: 3}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 3, col: 0}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 2, col: 2}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 3, col: 3}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 3, col: 2}, dot2: {row: 3, col: 3}}
                  ]
         },
         {
           id: 3,
           lines: [
                   {dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                   {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 0, col: 2}, state: :fixed},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 0, col: 3}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 2, col: 0}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 1, col: 2}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 1, col: 2}, dot2: {row: 2, col: 2}, state: :fixed},
                   {dot1: {row: 1, col: 3}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 3, col: 0}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 2, col: 2}, state: :fixed},
                   {dot1: {row: 2, col: 1}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 3, col: 3}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 3, col: 2}, dot2: {row: 3, col: 3}}
                  ]
         },
         {
           id: 4,
           lines: [
                   {dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                   {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 0, col: 2}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 0, col: 3}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 0, col: 4}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 0, col: 4}, dot2: {row: 1, col: 4}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 2, col: 0}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 1, col: 2}, dot2: {row: 1, col: 3}, state: :fixed},
                   {dot1: {row: 1, col: 2}, dot2: {row: 2, col: 2}},
                   {dot1: {row: 1, col: 3}, dot2: {row: 1, col: 4}},
                   {dot1: {row: 1, col: 3}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 1, col: 4}, dot2: {row: 2, col: 4}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 2, col: 1}, state: :fixed},
                   {dot1: {row: 2, col: 0}, dot2: {row: 3, col: 0}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 2, col: 2}, state: :fixed},
                   {dot1: {row: 2, col: 1}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 2, col: 4}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 3, col: 3}},
                   {dot1: {row: 2, col: 4}, dot2: {row: 3, col: 4}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 4, col: 0}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 4, col: 1}},
                   {dot1: {row: 3, col: 2}, dot2: {row: 3, col: 3}},
                   {dot1: {row: 3, col: 2}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 3, col: 3}, dot2: {row: 3, col: 4}},
                   {dot1: {row: 3, col: 3}, dot2: {row: 4, col: 3}},
                   {dot1: {row: 4, col: 0}, dot2: {row: 4, col: 1}},
                   {dot1: {row: 4, col: 1}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 4, col: 2}, dot2: {row: 4, col: 3}}
                  ]
         },
         {
           id: 5,
           lines: [
                   {dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                   {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 0, col: 2}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 0, col: 3}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 1, col: 2}, state: :fixed},
                   {dot1: {row: 0, col: 3}, dot2: {row: 0, col: 4}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 0, col: 4}, dot2: {row: 0, col: 5}},
                   {dot1: {row: 0, col: 4}, dot2: {row: 1, col: 4}},
                   {dot1: {row: 0, col: 5}, dot2: {row: 1, col: 5}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 2, col: 0}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 2, col: 1}, state: :fixed},
                   {dot1: {row: 1, col: 2}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 1, col: 2}, dot2: {row: 2, col: 2}},
                   {dot1: {row: 1, col: 3}, dot2: {row: 1, col: 4}},
                   {dot1: {row: 1, col: 3}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 1, col: 4}, dot2: {row: 1, col: 5}},
                   {dot1: {row: 1, col: 4}, dot2: {row: 2, col: 4}, state: :fixed},
                   {dot1: {row: 1, col: 5}, dot2: {row: 2, col: 5}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 3, col: 0}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 2, col: 2}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 2, col: 4}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 3, col: 3}},
                   {dot1: {row: 2, col: 4}, dot2: {row: 2, col: 5}},
                   {dot1: {row: 2, col: 4}, dot2: {row: 3, col: 4}},
                   {dot1: {row: 2, col: 5}, dot2: {row: 3, col: 5}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 4, col: 0}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 4, col: 1}},
                   {dot1: {row: 3, col: 2}, dot2: {row: 3, col: 3}, state: :fixed},
                   {dot1: {row: 3, col: 2}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 3, col: 3}, dot2: {row: 3, col: 4}},
                   {dot1: {row: 3, col: 3}, dot2: {row: 4, col: 3}, state: :fixed},
                   {dot1: {row: 3, col: 4}, dot2: {row: 3, col: 5}},
                   {dot1: {row: 3, col: 4}, dot2: {row: 4, col: 4}},
                   {dot1: {row: 3, col: 5}, dot2: {row: 4, col: 5}, state: :fixed},
                   {dot1: {row: 4, col: 0}, dot2: {row: 4, col: 1}},
                   {dot1: {row: 4, col: 0}, dot2: {row: 5, col: 0}},
                   {dot1: {row: 4, col: 1}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 4, col: 1}, dot2: {row: 5, col: 1}},
                   {dot1: {row: 4, col: 2}, dot2: {row: 4, col: 3}},
                   {dot1: {row: 4, col: 2}, dot2: {row: 5, col: 2}, state: :fixed},
                   {dot1: {row: 4, col: 3}, dot2: {row: 4, col: 4}},
                   {dot1: {row: 4, col: 3}, dot2: {row: 5, col: 3}},
                   {dot1: {row: 4, col: 4}, dot2: {row: 4, col: 5}},
                   {dot1: {row: 4, col: 4}, dot2: {row: 5, col: 4}},
                   {dot1: {row: 4, col: 5}, dot2: {row: 5, col: 5}},
                   {dot1: {row: 5, col: 0}, dot2: {row: 5, col: 1}},
                   {dot1: {row: 5, col: 1}, dot2: {row: 5, col: 2}},
                   {dot1: {row: 5, col: 2}, dot2: {row: 5, col: 3}},
                   {dot1: {row: 5, col: 3}, dot2: {row: 5, col: 4}},
                   {dot1: {row: 5, col: 4}, dot2: {row: 5, col: 5}}
                  ]
         },
         {
           # From the Monorail app, RECT 7x7 #30
           id: 6,
           lines: [
                   {dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                   {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 0, col: 2}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 0, col: 3}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 0, col: 4}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 0, col: 4}, dot2: {row: 0, col: 5}},
                   {dot1: {row: 0, col: 4}, dot2: {row: 1, col: 4}},
                   {dot1: {row: 0, col: 5}, dot2: {row: 0, col: 6}},
                   {dot1: {row: 0, col: 5}, dot2: {row: 1, col: 5}},
                   {dot1: {row: 0, col: 6}, dot2: {row: 1, col: 6}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 2, col: 0}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 1, col: 2}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 1, col: 2}, dot2: {row: 2, col: 2}},
                   {dot1: {row: 1, col: 3}, dot2: {row: 1, col: 4}},
                   {dot1: {row: 1, col: 3}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 1, col: 4}, dot2: {row: 1, col: 5}},
                   {dot1: {row: 1, col: 4}, dot2: {row: 2, col: 4}},
                   {dot1: {row: 1, col: 5}, dot2: {row: 1, col: 6}, state: :fixed},
                   {dot1: {row: 1, col: 5}, dot2: {row: 2, col: 5}},
                   {dot1: {row: 1, col: 6}, dot2: {row: 2, col: 6}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 3, col: 0}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 2, col: 2}, state: :fixed},
                   {dot1: {row: 2, col: 1}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 2, col: 4}},
                   {dot1: {row: 2, col: 4}, dot2: {row: 2, col: 5}},
                   {dot1: {row: 2, col: 4}, dot2: {row: 3, col: 4}},
                   {dot1: {row: 2, col: 5}, dot2: {row: 2, col: 6}},
                   {dot1: {row: 2, col: 5}, dot2: {row: 3, col: 5}},
                   {dot1: {row: 2, col: 6}, dot2: {row: 3, col: 6}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 4, col: 0}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 3, col: 2}, state: :fixed},
                   {dot1: {row: 3, col: 1}, dot2: {row: 4, col: 1}},
                   {dot1: {row: 3, col: 2}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 3, col: 4}, dot2: {row: 3, col: 5}},
                   {dot1: {row: 3, col: 4}, dot2: {row: 4, col: 4}},
                   {dot1: {row: 3, col: 5}, dot2: {row: 3, col: 6}},
                   {dot1: {row: 3, col: 5}, dot2: {row: 4, col: 5}},
                   {dot1: {row: 3, col: 6}, dot2: {row: 4, col: 6}},
                   {dot1: {row: 4, col: 0}, dot2: {row: 4, col: 1}, state: :fixed},
                   {dot1: {row: 4, col: 0}, dot2: {row: 5, col: 0}},
                   {dot1: {row: 4, col: 1}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 4, col: 1}, dot2: {row: 5, col: 1}},
                   {dot1: {row: 4, col: 2}, dot2: {row: 4, col: 3}},
                   {dot1: {row: 4, col: 2}, dot2: {row: 5, col: 2}},
                   {dot1: {row: 4, col: 3}, dot2: {row: 4, col: 4}},
                   {dot1: {row: 4, col: 3}, dot2: {row: 5, col: 3}},
                   {dot1: {row: 4, col: 4}, dot2: {row: 4, col: 5}},
                   {dot1: {row: 4, col: 4}, dot2: {row: 5, col: 4}},
                   {dot1: {row: 4, col: 5}, dot2: {row: 4, col: 6}},
                   {dot1: {row: 4, col: 5}, dot2: {row: 5, col: 5}},
                   {dot1: {row: 4, col: 6}, dot2: {row: 5, col: 6}},
                   {dot1: {row: 5, col: 0}, dot2: {row: 5, col: 1}},
                   {dot1: {row: 5, col: 0}, dot2: {row: 6, col: 0}},
                   {dot1: {row: 5, col: 1}, dot2: {row: 5, col: 2}},
                   {dot1: {row: 5, col: 1}, dot2: {row: 6, col: 1}},
                   {dot1: {row: 5, col: 2}, dot2: {row: 5, col: 3}},
                   {dot1: {row: 5, col: 2}, dot2: {row: 6, col: 2}},
                   {dot1: {row: 5, col: 3}, dot2: {row: 5, col: 4}, state: :fixed},
                   {dot1: {row: 5, col: 3}, dot2: {row: 6, col: 3}, state: :fixed},
                   {dot1: {row: 5, col: 4}, dot2: {row: 5, col: 5}},
                   {dot1: {row: 5, col: 4}, dot2: {row: 6, col: 4}},
                   {dot1: {row: 5, col: 5}, dot2: {row: 5, col: 6}, state: :fixed},
                   {dot1: {row: 5, col: 5}, dot2: {row: 6, col: 5}},
                   {dot1: {row: 5, col: 6}, dot2: {row: 6, col: 6}},
                   {dot1: {row: 6, col: 0}, dot2: {row: 6, col: 1}},
                   {dot1: {row: 6, col: 1}, dot2: {row: 6, col: 2}},
                   {dot1: {row: 6, col: 2}, dot2: {row: 6, col: 3}},
                   {dot1: {row: 6, col: 3}, dot2: {row: 6, col: 4}},
                   {dot1: {row: 6, col: 4}, dot2: {row: 6, col: 5}},
                   {dot1: {row: 6, col: 5}, dot2: {row: 6, col: 6}}
                  ]
         },
         {
           # From Glenn Iba's "ROUNDTRIP PUZZLES: Extended Introduction with solving strategies"
           # http://glenniba.com/Intro-long-web.pdf
           id: 7,
           lines: [{dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                   {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 0, col: 2}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 0, col: 3}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 0, col: 4}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 0, col: 4}, dot2: {row: 0, col: 5}},
                   {dot1: {row: 0, col: 4}, dot2: {row: 1, col: 4}, state: :fixed},
                   {dot1: {row: 0, col: 5}, dot2: {row: 0, col: 6}},
                   {dot1: {row: 0, col: 5}, dot2: {row: 1, col: 5}},
                   {dot1: {row: 0, col: 6}, dot2: {row: 0, col: 7}},
                   {dot1: {row: 0, col: 6}, dot2: {row: 1, col: 6}},
                   {dot1: {row: 0, col: 7}, dot2: {row: 1, col: 7}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 2, col: 0}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 1, col: 2}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 1, col: 2}, dot2: {row: 2, col: 2}},
                   {dot1: {row: 1, col: 3}, dot2: {row: 1, col: 4}},
                   {dot1: {row: 1, col: 3}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 1, col: 4}, dot2: {row: 1, col: 5}},
                   {dot1: {row: 1, col: 4}, dot2: {row: 2, col: 4}},
                   {dot1: {row: 1, col: 5}, dot2: {row: 1, col: 6}},
                   {dot1: {row: 1, col: 5}, dot2: {row: 2, col: 5}},
                   {dot1: {row: 1, col: 6}, dot2: {row: 1, col: 7}},
                   {dot1: {row: 1, col: 6}, dot2: {row: 2, col: 6}},
                   {dot1: {row: 1, col: 7}, dot2: {row: 2, col: 7}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 3, col: 0}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 2, col: 2}, state: :fixed},
                   {dot1: {row: 2, col: 1}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 3, col: 2}, state: :fixed},
                   {dot1: {row: 2, col: 3}, dot2: {row: 2, col: 4}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 3, col: 3}},
                   {dot1: {row: 2, col: 4}, dot2: {row: 2, col: 5}},
                   {dot1: {row: 2, col: 4}, dot2: {row: 3, col: 4}},
                   {dot1: {row: 2, col: 5}, dot2: {row: 2, col: 6}, state: :fixed},
                   {dot1: {row: 2, col: 5}, dot2: {row: 3, col: 5}},
                   {dot1: {row: 2, col: 6}, dot2: {row: 2, col: 7}},
                   {dot1: {row: 2, col: 6}, dot2: {row: 3, col: 6}},
                   {dot1: {row: 2, col: 7}, dot2: {row: 3, col: 7}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 4, col: 0}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 4, col: 1}},
                   {dot1: {row: 3, col: 2}, dot2: {row: 3, col: 3}},
                   {dot1: {row: 3, col: 2}, dot2: {row: 4, col: 2}, state: :fixed},
                   {dot1: {row: 3, col: 3}, dot2: {row: 3, col: 4}},
                   {dot1: {row: 3, col: 3}, dot2: {row: 4, col: 3}},
                   {dot1: {row: 3, col: 4}, dot2: {row: 3, col: 5}},
                   {dot1: {row: 3, col: 4}, dot2: {row: 4, col: 4}},
                   {dot1: {row: 3, col: 5}, dot2: {row: 3, col: 6}},
                   {dot1: {row: 3, col: 5}, dot2: {row: 4, col: 5}, state: :fixed},
                   {dot1: {row: 3, col: 6}, dot2: {row: 3, col: 7}},
                   {dot1: {row: 3, col: 6}, dot2: {row: 4, col: 6}},
                   {dot1: {row: 3, col: 7}, dot2: {row: 4, col: 7}, state: :fixed},
                   {dot1: {row: 4, col: 0}, dot2: {row: 4, col: 1}},
                   {dot1: {row: 4, col: 0}, dot2: {row: 5, col: 0}},
                   {dot1: {row: 4, col: 1}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 4, col: 1}, dot2: {row: 5, col: 1}},
                   {dot1: {row: 4, col: 2}, dot2: {row: 4, col: 3}, state: :fixed},
                   {dot1: {row: 4, col: 2}, dot2: {row: 5, col: 2}},
                   {dot1: {row: 4, col: 3}, dot2: {row: 4, col: 4}},
                   {dot1: {row: 4, col: 3}, dot2: {row: 5, col: 3}},
                   {dot1: {row: 4, col: 4}, dot2: {row: 4, col: 5}},
                   {dot1: {row: 4, col: 4}, dot2: {row: 5, col: 4}},
                   {dot1: {row: 4, col: 5}, dot2: {row: 4, col: 6}, state: :fixed},
                   {dot1: {row: 4, col: 5}, dot2: {row: 5, col: 5}},
                   {dot1: {row: 4, col: 6}, dot2: {row: 4, col: 7}},
                   {dot1: {row: 4, col: 6}, dot2: {row: 5, col: 6}},
                   {dot1: {row: 4, col: 7}, dot2: {row: 5, col: 7}},
                   {dot1: {row: 5, col: 0}, dot2: {row: 5, col: 1}, state: :fixed},
                   {dot1: {row: 5, col: 0}, dot2: {row: 6, col: 0}},
                   {dot1: {row: 5, col: 1}, dot2: {row: 5, col: 2}},
                   {dot1: {row: 5, col: 1}, dot2: {row: 6, col: 1}},
                   {dot1: {row: 5, col: 2}, dot2: {row: 5, col: 3}},
                   {dot1: {row: 5, col: 2}, dot2: {row: 6, col: 2}},
                   {dot1: {row: 5, col: 3}, dot2: {row: 5, col: 4}},
                   {dot1: {row: 5, col: 3}, dot2: {row: 6, col: 3}},
                   {dot1: {row: 5, col: 4}, dot2: {row: 5, col: 5}},
                   {dot1: {row: 5, col: 4}, dot2: {row: 6, col: 4}, state: :fixed},
                   {dot1: {row: 5, col: 5}, dot2: {row: 5, col: 6}},
                   {dot1: {row: 5, col: 5}, dot2: {row: 6, col: 5}},
                   {dot1: {row: 5, col: 6}, dot2: {row: 5, col: 7}},
                   {dot1: {row: 5, col: 6}, dot2: {row: 6, col: 6}},
                   {dot1: {row: 5, col: 7}, dot2: {row: 6, col: 7}},
                   {dot1: {row: 6, col: 0}, dot2: {row: 6, col: 1}},
                   {dot1: {row: 6, col: 0}, dot2: {row: 7, col: 0}},
                   {dot1: {row: 6, col: 1}, dot2: {row: 6, col: 2}},
                   {dot1: {row: 6, col: 1}, dot2: {row: 7, col: 1}},
                   {dot1: {row: 6, col: 2}, dot2: {row: 6, col: 3}},
                   {dot1: {row: 6, col: 2}, dot2: {row: 7, col: 2}},
                   {dot1: {row: 6, col: 3}, dot2: {row: 6, col: 4}, state: :fixed},
                   {dot1: {row: 6, col: 3}, dot2: {row: 7, col: 3}, state: :fixed},
                   {dot1: {row: 6, col: 4}, dot2: {row: 6, col: 5}},
                   {dot1: {row: 6, col: 4}, dot2: {row: 7, col: 4}},
                   {dot1: {row: 6, col: 5}, dot2: {row: 6, col: 6}},
                   {dot1: {row: 6, col: 5}, dot2: {row: 7, col: 5}},
                   {dot1: {row: 6, col: 6}, dot2: {row: 6, col: 7}},
                   {dot1: {row: 6, col: 6}, dot2: {row: 7, col: 6}},
                   {dot1: {row: 6, col: 7}, dot2: {row: 7, col: 7}},
                   {dot1: {row: 7, col: 0}, dot2: {row: 7, col: 1}},
                   {dot1: {row: 7, col: 1}, dot2: {row: 7, col: 2}},
                   {dot1: {row: 7, col: 2}, dot2: {row: 7, col: 3}},
                   {dot1: {row: 7, col: 3}, dot2: {row: 7, col: 4}},
                   {dot1: {row: 7, col: 4}, dot2: {row: 7, col: 5}},
                   {dot1: {row: 7, col: 5}, dot2: {row: 7, col: 6}, state: :fixed},
                   {dot1: {row: 7, col: 6}, dot2: {row: 7, col: 7}}
                  ]
         },
         {
           # From Otto Janko's Grand Tour, #230: http://www.janko.at/Raetsel/Grand-Tour/230.a.htm
           id: 8,
           lines: [
                   {dot1: {row: 0, col: 0}, dot2: {row: 0, col: 1}},
                   {dot1: {row: 0, col: 0}, dot2: {row: 1, col: 0}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 0, col: 2}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 0, col: 3}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 0, col: 4}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 0, col: 4}, dot2: {row: 0, col: 5}, state: :fixed},
                   {dot1: {row: 0, col: 4}, dot2: {row: 1, col: 4}},
                   {dot1: {row: 0, col: 5}, dot2: {row: 0, col: 6}, state: :fixed},
                   {dot1: {row: 0, col: 5}, dot2: {row: 1, col: 5}},
                   {dot1: {row: 0, col: 6}, dot2: {row: 0, col: 7}},
                   {dot1: {row: 0, col: 6}, dot2: {row: 1, col: 6}},
                   {dot1: {row: 0, col: 7}, dot2: {row: 0, col: 8}},
                   {dot1: {row: 0, col: 7}, dot2: {row: 1, col: 7}, state: :fixed},
                   {dot1: {row: 0, col: 8}, dot2: {row: 0, col: 9}},
                   {dot1: {row: 0, col: 8}, dot2: {row: 1, col: 8}},
                   {dot1: {row: 0, col: 9}, dot2: {row: 0, col: 10}},
                   {dot1: {row: 0, col: 9}, dot2: {row: 1, col: 9}},
                   {dot1: {row: 0, col: 10}, dot2: {row: 0, col: 11}},
                   {dot1: {row: 0, col: 10}, dot2: {row: 1, col: 10}},
                   {dot1: {row: 0, col: 11}, dot2: {row: 1, col: 11}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 1, col: 1}},
                   {dot1: {row: 1, col: 0}, dot2: {row: 2, col: 0}, state: :fixed},
                   {dot1: {row: 1, col: 1}, dot2: {row: 1, col: 2}},
                   {dot1: {row: 1, col: 1}, dot2: {row: 2, col: 1}, state: :fixed},
                   {dot1: {row: 1, col: 2}, dot2: {row: 1, col: 3}},
                   {dot1: {row: 1, col: 2}, dot2: {row: 2, col: 2}, state: :fixed},
                   {dot1: {row: 1, col: 3}, dot2: {row: 1, col: 4}, state: :fixed},
                   {dot1: {row: 1, col: 3}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 1, col: 4}, dot2: {row: 1, col: 5}},
                   {dot1: {row: 1, col: 4}, dot2: {row: 2, col: 4}},
                   {dot1: {row: 1, col: 5}, dot2: {row: 1, col: 6}},
                   {dot1: {row: 1, col: 5}, dot2: {row: 2, col: 5}},
                   {dot1: {row: 1, col: 6}, dot2: {row: 1, col: 7}},
                   {dot1: {row: 1, col: 6}, dot2: {row: 2, col: 6}},
                   {dot1: {row: 1, col: 7}, dot2: {row: 1, col: 8}, state: :fixed},
                   {dot1: {row: 1, col: 7}, dot2: {row: 2, col: 7}},
                   {dot1: {row: 1, col: 8}, dot2: {row: 1, col: 9}},
                   {dot1: {row: 1, col: 8}, dot2: {row: 2, col: 8}},
                   {dot1: {row: 1, col: 9}, dot2: {row: 1, col: 10}},
                   {dot1: {row: 1, col: 9}, dot2: {row: 2, col: 9}},
                   {dot1: {row: 1, col: 10}, dot2: {row: 1, col: 11}},
                   {dot1: {row: 1, col: 10}, dot2: {row: 2, col: 10}, state: :fixed},
                   {dot1: {row: 1, col: 11}, dot2: {row: 2, col: 11}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 3, col: 0}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 2, col: 2}, state: :fixed},
                   {dot1: {row: 2, col: 1}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 2, col: 4}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 3, col: 3}},
                   {dot1: {row: 2, col: 4}, dot2: {row: 2, col: 5}},
                   {dot1: {row: 2, col: 4}, dot2: {row: 3, col: 4}, state: :fixed},
                   {dot1: {row: 2, col: 5}, dot2: {row: 2, col: 6}},
                   {dot1: {row: 2, col: 5}, dot2: {row: 3, col: 5}},
                   {dot1: {row: 2, col: 6}, dot2: {row: 2, col: 7}},
                   {dot1: {row: 2, col: 6}, dot2: {row: 3, col: 6}},
                   {dot1: {row: 2, col: 7}, dot2: {row: 2, col: 8}},
                   {dot1: {row: 2, col: 7}, dot2: {row: 3, col: 7}, state: :fixed},
                   {dot1: {row: 2, col: 8}, dot2: {row: 2, col: 9}},
                   {dot1: {row: 2, col: 8}, dot2: {row: 3, col: 8}},
                   {dot1: {row: 2, col: 9}, dot2: {row: 2, col: 10}, state: :fixed},
                   {dot1: {row: 2, col: 9}, dot2: {row: 3, col: 9}},
                   {dot1: {row: 2, col: 10}, dot2: {row: 2, col: 11}},
                   {dot1: {row: 2, col: 10}, dot2: {row: 3, col: 10}},
                   {dot1: {row: 2, col: 11}, dot2: {row: 3, col: 11}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 3, col: 1}},
                   {dot1: {row: 3, col: 0}, dot2: {row: 4, col: 0}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 3, col: 2}},
                   {dot1: {row: 3, col: 1}, dot2: {row: 4, col: 1}, state: :fixed},
                   {dot1: {row: 3, col: 2}, dot2: {row: 3, col: 3}},
                   {dot1: {row: 3, col: 2}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 3, col: 3}, dot2: {row: 3, col: 4}, state: :fixed},
                   {dot1: {row: 3, col: 3}, dot2: {row: 4, col: 3}},
                   {dot1: {row: 3, col: 4}, dot2: {row: 3, col: 5}},
                   {dot1: {row: 3, col: 4}, dot2: {row: 4, col: 4}},
                   {dot1: {row: 3, col: 5}, dot2: {row: 3, col: 6}},
                   {dot1: {row: 3, col: 5}, dot2: {row: 4, col: 5}, state: :fixed},
                   {dot1: {row: 3, col: 6}, dot2: {row: 3, col: 7}},
                   {dot1: {row: 3, col: 6}, dot2: {row: 4, col: 6}, state: :fixed},
                   {dot1: {row: 3, col: 7}, dot2: {row: 3, col: 8}},
                   {dot1: {row: 3, col: 7}, dot2: {row: 4, col: 7}},
                   {dot1: {row: 3, col: 8}, dot2: {row: 3, col: 9}, state: :fixed},
                   {dot1: {row: 3, col: 8}, dot2: {row: 4, col: 8}},
                   {dot1: {row: 3, col: 9}, dot2: {row: 3, col: 10}},
                   {dot1: {row: 3, col: 9}, dot2: {row: 4, col: 9}},
                   {dot1: {row: 3, col: 10}, dot2: {row: 3, col: 11}},
                   {dot1: {row: 3, col: 10}, dot2: {row: 4, col: 10}, state: :fixed},
                   {dot1: {row: 3, col: 11}, dot2: {row: 4, col: 11}},
                   {dot1: {row: 4, col: 0}, dot2: {row: 4, col: 1}},
                   {dot1: {row: 4, col: 0}, dot2: {row: 5, col: 0}, state: :fixed},
                   {dot1: {row: 4, col: 1}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 4, col: 1}, dot2: {row: 5, col: 1}},
                   {dot1: {row: 4, col: 2}, dot2: {row: 4, col: 3}, state: :fixed},
                   {dot1: {row: 4, col: 2}, dot2: {row: 5, col: 2}},
                   {dot1: {row: 4, col: 3}, dot2: {row: 4, col: 4}},
                   {dot1: {row: 4, col: 3}, dot2: {row: 5, col: 3}, state: :fixed},
                   {dot1: {row: 4, col: 4}, dot2: {row: 4, col: 5}},
                   {dot1: {row: 4, col: 4}, dot2: {row: 5, col: 4}},
                   {dot1: {row: 4, col: 5}, dot2: {row: 4, col: 6}},
                   {dot1: {row: 4, col: 5}, dot2: {row: 5, col: 5}},
                   {dot1: {row: 4, col: 6}, dot2: {row: 4, col: 7}},
                   {dot1: {row: 4, col: 6}, dot2: {row: 5, col: 6}, state: :fixed},
                   {dot1: {row: 4, col: 7}, dot2: {row: 4, col: 8}},
                   {dot1: {row: 4, col: 7}, dot2: {row: 5, col: 7}},
                   {dot1: {row: 4, col: 8}, dot2: {row: 4, col: 9}},
                   {dot1: {row: 4, col: 8}, dot2: {row: 5, col: 8}},
                   {dot1: {row: 4, col: 9}, dot2: {row: 4, col: 10}, state: :fixed},
                   {dot1: {row: 4, col: 9}, dot2: {row: 5, col: 9}},
                   {dot1: {row: 4, col: 10}, dot2: {row: 4, col: 11}},
                   {dot1: {row: 4, col: 10}, dot2: {row: 5, col: 10}},
                   {dot1: {row: 4, col: 11}, dot2: {row: 5, col: 11}},
                   {dot1: {row: 5, col: 0}, dot2: {row: 5, col: 1}},
                   {dot1: {row: 5, col: 0}, dot2: {row: 6, col: 0}},
                   {dot1: {row: 5, col: 1}, dot2: {row: 5, col: 2}},
                   {dot1: {row: 5, col: 1}, dot2: {row: 6, col: 1}},
                   {dot1: {row: 5, col: 2}, dot2: {row: 5, col: 3}},
                   {dot1: {row: 5, col: 2}, dot2: {row: 6, col: 2}},
                   {dot1: {row: 5, col: 3}, dot2: {row: 5, col: 4}},
                   {dot1: {row: 5, col: 3}, dot2: {row: 6, col: 3}},
                   {dot1: {row: 5, col: 4}, dot2: {row: 5, col: 5}},
                   {dot1: {row: 5, col: 4}, dot2: {row: 6, col: 4}, state: :fixed},
                   {dot1: {row: 5, col: 5}, dot2: {row: 5, col: 6}},
                   {dot1: {row: 5, col: 5}, dot2: {row: 6, col: 5}},
                   {dot1: {row: 5, col: 6}, dot2: {row: 5, col: 7}},
                   {dot1: {row: 5, col: 6}, dot2: {row: 6, col: 6}},
                   {dot1: {row: 5, col: 7}, dot2: {row: 5, col: 8}, state: :fixed},
                   {dot1: {row: 5, col: 7}, dot2: {row: 6, col: 7}},
                   {dot1: {row: 5, col: 8}, dot2: {row: 5, col: 9}},
                   {dot1: {row: 5, col: 8}, dot2: {row: 6, col: 8}},
                   {dot1: {row: 5, col: 9}, dot2: {row: 5, col: 10}},
                   {dot1: {row: 5, col: 9}, dot2: {row: 6, col: 9}, state: :fixed},
                   {dot1: {row: 5, col: 10}, dot2: {row: 5, col: 11}},
                   {dot1: {row: 5, col: 10}, dot2: {row: 6, col: 10}},
                   {dot1: {row: 5, col: 11}, dot2: {row: 6, col: 11}},
                   {dot1: {row: 6, col: 0}, dot2: {row: 6, col: 1}, state: :fixed},
                   {dot1: {row: 6, col: 0}, dot2: {row: 7, col: 0}},
                   {dot1: {row: 6, col: 1}, dot2: {row: 6, col: 2}, state: :fixed},
                   {dot1: {row: 6, col: 1}, dot2: {row: 7, col: 1}},
                   {dot1: {row: 6, col: 2}, dot2: {row: 6, col: 3}},
                   {dot1: {row: 6, col: 2}, dot2: {row: 7, col: 2}, state: :fixed},
                   {dot1: {row: 6, col: 3}, dot2: {row: 6, col: 4}},
                   {dot1: {row: 6, col: 3}, dot2: {row: 7, col: 3}},
                   {dot1: {row: 6, col: 4}, dot2: {row: 6, col: 5}},
                   {dot1: {row: 6, col: 4}, dot2: {row: 7, col: 4}},
                   {dot1: {row: 6, col: 5}, dot2: {row: 6, col: 6}},
                   {dot1: {row: 6, col: 5}, dot2: {row: 7, col: 5}},
                   {dot1: {row: 6, col: 6}, dot2: {row: 6, col: 7}},
                   {dot1: {row: 6, col: 6}, dot2: {row: 7, col: 6}},
                   {dot1: {row: 6, col: 7}, dot2: {row: 6, col: 8}},
                   {dot1: {row: 6, col: 7}, dot2: {row: 7, col: 7}},
                   {dot1: {row: 6, col: 8}, dot2: {row: 6, col: 9}, state: :fixed},
                   {dot1: {row: 6, col: 8}, dot2: {row: 7, col: 8}, state: :fixed},
                   {dot1: {row: 6, col: 9}, dot2: {row: 6, col: 10}},
                   {dot1: {row: 6, col: 9}, dot2: {row: 7, col: 9}},
                   {dot1: {row: 6, col: 10}, dot2: {row: 6, col: 11}},
                   {dot1: {row: 6, col: 10}, dot2: {row: 7, col: 10}},
                   {dot1: {row: 6, col: 11}, dot2: {row: 7, col: 11}},
                   {dot1: {row: 7, col: 0}, dot2: {row: 7, col: 1}},
                   {dot1: {row: 7, col: 0}, dot2: {row: 8, col: 0}},
                   {dot1: {row: 7, col: 1}, dot2: {row: 7, col: 2}},
                   {dot1: {row: 7, col: 1}, dot2: {row: 8, col: 1}, state: :fixed},
                   {dot1: {row: 7, col: 2}, dot2: {row: 7, col: 3}},
                   {dot1: {row: 7, col: 2}, dot2: {row: 8, col: 2}},
                   {dot1: {row: 7, col: 3}, dot2: {row: 7, col: 4}},
                   {dot1: {row: 7, col: 3}, dot2: {row: 8, col: 3}, state: :fixed},
                   {dot1: {row: 7, col: 4}, dot2: {row: 7, col: 5}},
                   {dot1: {row: 7, col: 4}, dot2: {row: 8, col: 4}},
                   {dot1: {row: 7, col: 5}, dot2: {row: 7, col: 6}},
                   {dot1: {row: 7, col: 5}, dot2: {row: 8, col: 5}},
                   {dot1: {row: 7, col: 6}, dot2: {row: 7, col: 7}},
                   {dot1: {row: 7, col: 6}, dot2: {row: 8, col: 6}},
                   {dot1: {row: 7, col: 7}, dot2: {row: 7, col: 8}},
                   {dot1: {row: 7, col: 7}, dot2: {row: 8, col: 7}},
                   {dot1: {row: 7, col: 8}, dot2: {row: 7, col: 9}},
                   {dot1: {row: 7, col: 8}, dot2: {row: 8, col: 8}},
                   {dot1: {row: 7, col: 9}, dot2: {row: 7, col: 10}},
                   {dot1: {row: 7, col: 9}, dot2: {row: 8, col: 9}},
                   {dot1: {row: 7, col: 10}, dot2: {row: 7, col: 11}},
                   {dot1: {row: 7, col: 10}, dot2: {row: 8, col: 10}},
                   {dot1: {row: 7, col: 11}, dot2: {row: 8, col: 11}},
                   {dot1: {row: 8, col: 0}, dot2: {row: 8, col: 1}},
                   {dot1: {row: 8, col: 0}, dot2: {row: 9, col: 0}},
                   {dot1: {row: 8, col: 1}, dot2: {row: 8, col: 2}},
                   {dot1: {row: 8, col: 1}, dot2: {row: 9, col: 1}},
                   {dot1: {row: 8, col: 2}, dot2: {row: 8, col: 3}},
                   {dot1: {row: 8, col: 2}, dot2: {row: 9, col: 2}, state: :fixed},
                   {dot1: {row: 8, col: 3}, dot2: {row: 8, col: 4}},
                   {dot1: {row: 8, col: 3}, dot2: {row: 9, col: 3}, state: :fixed},
                   {dot1: {row: 8, col: 4}, dot2: {row: 8, col: 5}},
                   {dot1: {row: 8, col: 4}, dot2: {row: 9, col: 4}},
                   {dot1: {row: 8, col: 5}, dot2: {row: 8, col: 6}, state: :fixed},
                   {dot1: {row: 8, col: 5}, dot2: {row: 9, col: 5}},
                   {dot1: {row: 8, col: 6}, dot2: {row: 8, col: 7}},
                   {dot1: {row: 8, col: 6}, dot2: {row: 9, col: 6}, state: :fixed},
                   {dot1: {row: 8, col: 7}, dot2: {row: 8, col: 8}},
                   {dot1: {row: 8, col: 7}, dot2: {row: 9, col: 7}},
                   {dot1: {row: 8, col: 8}, dot2: {row: 8, col: 9}, state: :fixed},
                   {dot1: {row: 8, col: 8}, dot2: {row: 9, col: 8}},
                   {dot1: {row: 8, col: 9}, dot2: {row: 8, col: 10}},
                   {dot1: {row: 8, col: 9}, dot2: {row: 9, col: 9}},
                   {dot1: {row: 8, col: 10}, dot2: {row: 8, col: 11}},
                   {dot1: {row: 8, col: 10}, dot2: {row: 9, col: 10}},
                   {dot1: {row: 8, col: 11}, dot2: {row: 9, col: 11}},
                   {dot1: {row: 9, col: 0}, dot2: {row: 9, col: 1}},
                   {dot1: {row: 9, col: 0}, dot2: {row: 10, col: 0}},
                   {dot1: {row: 9, col: 1}, dot2: {row: 9, col: 2}},
                   {dot1: {row: 9, col: 1}, dot2: {row: 10, col: 1}},
                   {dot1: {row: 9, col: 2}, dot2: {row: 9, col: 3}},
                   {dot1: {row: 9, col: 2}, dot2: {row: 10, col: 2}},
                   {dot1: {row: 9, col: 3}, dot2: {row: 9, col: 4}},
                   {dot1: {row: 9, col: 3}, dot2: {row: 10, col: 3}},
                   {dot1: {row: 9, col: 4}, dot2: {row: 9, col: 5}, state: :fixed},
                   {dot1: {row: 9, col: 4}, dot2: {row: 10, col: 4}},
                   {dot1: {row: 9, col: 5}, dot2: {row: 9, col: 6}},
                   {dot1: {row: 9, col: 5}, dot2: {row: 10, col: 5}},
                   {dot1: {row: 9, col: 6}, dot2: {row: 9, col: 7}, state: :fixed},
                   {dot1: {row: 9, col: 6}, dot2: {row: 10, col: 6}},
                   {dot1: {row: 9, col: 7}, dot2: {row: 9, col: 8}},
                   {dot1: {row: 9, col: 7}, dot2: {row: 10, col: 7}},
                   {dot1: {row: 9, col: 8}, dot2: {row: 9, col: 9}},
                   {dot1: {row: 9, col: 8}, dot2: {row: 10, col: 8}},
                   {dot1: {row: 9, col: 9}, dot2: {row: 9, col: 10}},
                   {dot1: {row: 9, col: 9}, dot2: {row: 10, col: 9}},
                   {dot1: {row: 9, col: 10}, dot2: {row: 9, col: 11}, state: :fixed},
                   {dot1: {row: 9, col: 10}, dot2: {row: 10, col: 10}},
                   {dot1: {row: 9, col: 11}, dot2: {row: 10, col: 11}},
                   {dot1: {row: 10, col: 0}, dot2: {row: 10, col: 1}},
                   {dot1: {row: 10, col: 0}, dot2: {row: 11, col: 0}},
                   {dot1: {row: 10, col: 1}, dot2: {row: 10, col: 2}},
                   {dot1: {row: 10, col: 1}, dot2: {row: 11, col: 1}, state: :fixed},
                   {dot1: {row: 10, col: 2}, dot2: {row: 10, col: 3}},
                   {dot1: {row: 10, col: 2}, dot2: {row: 11, col: 2}},
                   {dot1: {row: 10, col: 3}, dot2: {row: 10, col: 4}},
                   {dot1: {row: 10, col: 3}, dot2: {row: 11, col: 3}},
                   {dot1: {row: 10, col: 4}, dot2: {row: 10, col: 5}},
                   {dot1: {row: 10, col: 4}, dot2: {row: 11, col: 4}, state: :fixed},
                   {dot1: {row: 10, col: 5}, dot2: {row: 10, col: 6}},
                   {dot1: {row: 10, col: 5}, dot2: {row: 11, col: 5}},
                   {dot1: {row: 10, col: 6}, dot2: {row: 10, col: 7}},
                   {dot1: {row: 10, col: 6}, dot2: {row: 11, col: 6}},
                   {dot1: {row: 10, col: 7}, dot2: {row: 10, col: 8}},
                   {dot1: {row: 10, col: 7}, dot2: {row: 11, col: 7}, state: :fixed},
                   {dot1: {row: 10, col: 8}, dot2: {row: 10, col: 9}},
                   {dot1: {row: 10, col: 8}, dot2: {row: 11, col: 8}, state: :fixed},
                   {dot1: {row: 10, col: 9}, dot2: {row: 10, col: 10}},
                   {dot1: {row: 10, col: 9}, dot2: {row: 11, col: 9}},
                   {dot1: {row: 10, col: 10}, dot2: {row: 10, col: 11}},
                   {dot1: {row: 10, col: 10}, dot2: {row: 11, col: 10}, state: :fixed},
                   {dot1: {row: 10, col: 11}, dot2: {row: 11, col: 11}},
                   {dot1: {row: 11, col: 0}, dot2: {row: 11, col: 1}},
                   {dot1: {row: 11, col: 1}, dot2: {row: 11, col: 2}},
                   {dot1: {row: 11, col: 2}, dot2: {row: 11, col: 3}},
                   {dot1: {row: 11, col: 3}, dot2: {row: 11, col: 4}},
                   {dot1: {row: 11, col: 4}, dot2: {row: 11, col: 5}},
                   {dot1: {row: 11, col: 5}, dot2: {row: 11, col: 6}},
                   {dot1: {row: 11, col: 6}, dot2: {row: 11, col: 7}, state: :fixed},
                   {dot1: {row: 11, col: 7}, dot2: {row: 11, col: 8}},
                   {dot1: {row: 11, col: 8}, dot2: {row: 11, col: 9}, state: :fixed},
                   {dot1: {row: 11, col: 9}, dot2: {row: 11, col: 10}},
                   {dot1: {row: 11, col: 10}, dot2: {row: 11, col: 11}},
                  ],
         },
         {
           # From the Monorail app, CLASSIC Hex 5x5 EASY #1
           id: 9,
           lines: [
                   {dot1: {row: 0, col: 1}, dot2: {row: 0, col: 2}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 0.5}},
                   {dot1: {row: 0, col: 1}, dot2: {row: 1, col: 1.5}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 0, col: 3}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 1, col: 1.5}},
                   {dot1: {row: 0, col: 2}, dot2: {row: 1, col: 2.5}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 1, col: 2.5}},
                   {dot1: {row: 0, col: 3}, dot2: {row: 1, col: 3.5}},
                   {dot1: {row: 1, col: 0.5}, dot2: {row: 1, col: 1.5}},
                   {dot1: {row: 1, col: 0.5}, dot2: {row: 2, col: 0}},
                   {dot1: {row: 1, col: 0.5}, dot2: {row: 2, col: 1}, state: :fixed},
                   {dot1: {row: 1, col: 1.5}, dot2: {row: 1, col: 2.5}, state: :fixed},
                   {dot1: {row: 1, col: 1.5}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 1, col: 1.5}, dot2: {row: 2, col: 2}},
                   {dot1: {row: 1, col: 2.5}, dot2: {row: 1, col: 3.5}},
                   {dot1: {row: 1, col: 2.5}, dot2: {row: 2, col: 2}},
                   {dot1: {row: 1, col: 2.5}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 1, col: 3.5}, dot2: {row: 2, col: 3}},
                   {dot1: {row: 1, col: 3.5}, dot2: {row: 2, col: 4}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 2, col: 1}},
                   {dot1: {row: 2, col: 0}, dot2: {row: 3, col: 0.5}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 2, col: 2}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 3, col: 0.5}},
                   {dot1: {row: 2, col: 1}, dot2: {row: 3, col: 1.5}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 2, col: 3}, state: :fixed},
                   {dot1: {row: 2, col: 2}, dot2: {row: 3, col: 1.5}},
                   {dot1: {row: 2, col: 2}, dot2: {row: 3, col: 2.5}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 2, col: 4}, state: :fixed},
                   {dot1: {row: 2, col: 3}, dot2: {row: 3, col: 2.5}},
                   {dot1: {row: 2, col: 3}, dot2: {row: 3, col: 3.5}},
                   {dot1: {row: 2, col: 4}, dot2: {row: 3, col: 3.5}},
                   {dot1: {row: 3, col: 0.5}, dot2: {row: 3, col: 1.5}},
                   {dot1: {row: 3, col: 0.5}, dot2: {row: 4, col: 1}},
                   {dot1: {row: 3, col: 1.5}, dot2: {row: 3, col: 2.5}, state: :fixed},
                   {dot1: {row: 3, col: 1.5}, dot2: {row: 4, col: 1}},
                   {dot1: {row: 3, col: 1.5}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 3, col: 2.5}, dot2: {row: 3, col: 3.5}},
                   {dot1: {row: 3, col: 2.5}, dot2: {row: 4, col: 2}, state: :fixed},
                   {dot1: {row: 3, col: 2.5}, dot2: {row: 4, col: 3}},
                   {dot1: {row: 3, col: 3.5}, dot2: {row: 4, col: 3}},
                   {dot1: {row: 4, col: 1}, dot2: {row: 4, col: 2}},
                   {dot1: {row: 4, col: 2}, dot2: {row: 4, col: 3}}
                  ]
         }
        ]
    end

    adapter Adapter
  end
end
