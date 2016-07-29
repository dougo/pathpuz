require 'vienna'

module Monorail
  class HintRule < Vienna::Model
    include Vienna::Observable

    attributes :type, :auto

    def applicable?(puzzle)
      case type
      when :every_dot_has_two_lines
        puzzle.dots.find { |dot| dot.completable? == :present }
      when :every_dot_has_only_two_lines
        puzzle.dots.find { |dot| dot.completable? == :absent }
      when :short_loop_line
        total_dots = puzzle.dots.length
        puzzle.lines.find do |line|
          if line.unknown?
            dots = line.dot1.connected_dots
            dots.length < total_dots && dots.include?(line.dot2)
          end
        end
      when :short_loop_dot
        puzzle.dots.each do |dot|
          if dot.present_lines.empty? && dot.unknown_lines.length == 3
            line1, line2, line3 = dot.unknown_lines
            dot1, dot2, dot3 = dot.unknown_lines.map { |l| l.other_dot(dot) }
            dot1_dots = dot1.connected_dots
            if dot1_dots.include?(dot2)
              return line3
            elsif dot1_dots.include?(dot3)
              return line2
            elsif dot2.connected_dots.include?(dot3)
              return line1
            end
          end
        end
        false
      end
    end

    def apply(puzzle)
      case type
      when :every_dot_has_two_lines, :every_dot_has_only_two_lines
        dot = applicable?(puzzle)
        dot.complete! if dot
      when :short_loop_line
        line = applicable?(puzzle)
        line.mark_absent! if line
      when :short_loop_dot
        line = applicable?(puzzle)
        line.mark_present! if line
      end
    end
  end
end
