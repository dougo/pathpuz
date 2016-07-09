require 'vienna'

module Monorail
  class Application < Vienna::Model
    include Vienna::Observable

    attributes :puzzle, :autohint

    def initialize
      self.puzzle = Puzzle.find(0)
    end
  end
end

