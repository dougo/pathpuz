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

    def initialize(*args)
      super
      on(:lines_changed) do
        trigger(:solved) if solved?
      end
    end

    def lines=(lines)
      dots = lines.map { |l| l[:dot1] } + lines.map { |l| l[:dot2] }
      @dots = dots.uniq.map { |dot| [dot, Dot.new(dot)] }.to_h
      @dots.values.each do |dot|
        dot.on(:completed) do |state, *lines|
          trigger(:lines_changed, *lines)
        end
      end

      @lines = lines.map do |line|
        Line.new(dot1: @dots[line[:dot1]], dot2: @dots[line[:dot2]], state: line[:state])
      end

      @lines.each do |line|
        line.on(:next_state) do
          trigger(:lines_changed, line)
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

    def height
      dots.map(&:row).max + 1
    end

    def width
      dots.map(&:col).max + 1
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

    def find_completable_dot
      dots.find &:completable?
    end

    def hint!
      dot = find_completable_dot
      dot.complete! if dot
    end

    class Adapter < Vienna::Adapter
      def find(record, id, &block)
        if id <= 4
          attrs = puzzles[id]
        else
          attrs = record.class.json_for_size(id+1)
          attrs[:id] = id
        end
        model = record.class.load(attrs)
        block.call(model) if block
        model
      end

      def puzzles
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
         }
        ]
      end
    end

    adapter Adapter
  end
end
