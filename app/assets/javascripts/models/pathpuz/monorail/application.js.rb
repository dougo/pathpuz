require 'vienna'

module Monorail
  class Application < Vienna::Model
    include Vienna::Observable

    attributes :router, :puzzle, :autohint, :hint_rules

    def initialize(*args)
      super

      self.hint_rules ||= [HintRule.new(type: :every_dot_has_two_lines),
                           HintRule.new(type: :every_dot_has_only_two_lines),
                           HintRule.new(type: :single_loop)]

      self.autohint ||= false

      self.router = Vienna::Router.new
      router.route(':id') { |params| self.puzzle_id = params[:id].to_i }
      router.route('/') { self.puzzle_id = 0 }
      router.update
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

    def can_hint?
      hint_rules.any? { |rule| rule.applicable?(puzzle) }
    end

    def hint!
      rule = hint_rules.find { |rule| rule.applicable?(puzzle) }
      rule.apply(puzzle) if rule
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
      if autohint && puzzle
        puzzle.with_changes_combined { hint! }
      end
    end
  end
end
