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

    def prev_puzzle!
      if puzzle.id > 1
        router.navigate(puzzle.id - 1)
      else
        router.navigate('')
      end
    end

    def puzzle=(puzzle)
      @puzzle.off(:lines_changed, @handler) if @handler
      @puzzle = puzzle
      @handler = puzzle.on(:lines_changed) { autohint! }
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

