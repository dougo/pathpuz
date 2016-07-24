require 'vienna'

module Monorail
  class HintRule < Vienna::Model
    include Vienna::Observable

    attributes :type, :disabled

    def applicable?(puzzle)
      return false if disabled
      case type
      when :every_dot_has_two_lines
        puzzle.dots.find { |dot| dot.completable? == :present }
      when :every_dot_has_only_two_lines
        puzzle.dots.find { |dot| dot.completable? == :absent }
      when :single_loop
        total_dots = puzzle.dots.length
        puzzle.lines.find do |line|
          if line.unknown?
            dots = line.dot1.connected_dots
            dots.length < total_dots && dots.include?(line.dot2)
          end
        end
      end
    end

    def apply(puzzle)
      return if disabled
      case type
      when :every_dot_has_two_lines, :every_dot_has_only_two_lines
        dot = applicable?(puzzle)
        dot.complete! if dot
      when :single_loop
        line = applicable?(puzzle)
        line.mark_absent!
      end
    end
  end
end
