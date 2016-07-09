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

      # TODO: router.navigate instead?
      self.puzzle = Puzzle.find(0)

      self.autohint ||= false
    end

    private

    def puzzle_id=(id)
      self.puzzle = Puzzle.find(id)
    end
  end
end

