require 'vienna'

module Monorail
  class Application < Vienna::Model
    include Vienna::Observable

    attributes :router, :puzzle, :autohint

    def initialize(*args)
      super

      self.router = Vienna::Router.new
      router.route(':id') { |params| self.puzzle_id = params[:id].to_i }
      router.route('/') { self.puzzle_id = 0 }
      router.update

      self.autohint ||= false
    end

    def next_puzzle!
      router.navigate(puzzle.id + 1)
    end

    def puzzle=(puzzle)
      @puzzle = puzzle
      # TODO: remove old handler from previous puzzle?
      puzzle.on(:lines_changed) { autohint! }
      autohint!
    end

    def autohint=(autohint)
      @autohint = autohint
      autohint!
    end

    private

    def puzzle_id=(id)
      self.puzzle = Puzzle.find(id)
    end

    def autohint!
      puzzle.hint! if autohint && puzzle
    end
  end
end

