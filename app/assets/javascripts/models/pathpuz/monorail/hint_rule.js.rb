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
      end
    end

    def apply(puzzle)
      return if disabled
      case type
      when :every_dot_has_two_lines, :every_dot_has_only_two_lines
        dot = applicable?(puzzle)
        dot.complete! if dot
      end
    end
  end
end
