require 'vienna'

module Monorail
  class HintRule < Vienna::Model
    include Vienna::Observable

    attribute :disabled

    def applicable?(puzzle)
      puzzle.find_completable_dot unless disabled
    end

    def apply(puzzle)
      unless disabled
        dot = puzzle.find_completable_dot
        dot.complete! if dot
      end
    end
  end
end
