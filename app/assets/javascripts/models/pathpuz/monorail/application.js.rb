require 'vienna'

module Monorail
  class Application < Vienna::Model
    include Vienna::Observable

    attributes :router, :puzzle, :hint_rules

    def initialize(*args)
      super

      self.hint_rules ||= [HintRule.new(type: :every_dot_has_two_lines),
                           HintRule.new(type: :every_dot_has_only_two_lines),
                           HintRule.new(type: :short_loop_line),
                           HintRule.new(type: :short_loop_dot)]
      hint_rules.each do |rule|
        rule.add_observer(:auto) { |auto| autohint! if auto }
      end

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
      report_time('autohint') { autohint! }
    end

    def can_hint?
      hint_rules.any? { |rule| rule.applicable?(puzzle) }
    end

    def hint!
      rule = hint_rules.find { |rule| rule.applicable?(puzzle) }
      rule.apply(puzzle) if rule
    end

    private

    def report_time(msg)
      start = Time.now
      yield
      elapsed = Time.now - start
      puts "#{msg}: #{elapsed}s"
    end

    def puzzle_id=(id)
      self.puzzle = Puzzle.find(id)
    end

    def autohint_rules
      hint_rules.select(&:auto)
    end

    def autohint!
      if puzzle
        rule = autohint_rules.find { |rule| rule.applicable?(puzzle) }
        if rule
          puzzle.with_changes_combined { rule.apply(puzzle) }
        end
      end
    end
  end
end
