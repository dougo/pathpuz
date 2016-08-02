require 'vienna'

module Monorail
  class ApplicationView < Vienna::View
    attr_accessor :model

    element '#puzzle'

    def initialize(model)
      self.model = model
      model.add_observer(:puzzle) { render }
    end

    def render
      element.empty << render_instructions << render_puzzle << render_buttons << render_hint_rules
      self
    end

    on(:click, '.prev') { model.prev_puzzle! }
    on(:click, '.next') { model.next_puzzle! }

    private

    def render_instructions
      Element.new(:p).text('Build a monorail loop that visits every dot.')
    end

    def render_puzzle
      PuzzleView.new(model.puzzle).render.element
    end

    def render_buttons
      prev = Element.new(:button).add_class('prev').text('Previous puzzle').prop(:disabled, model.puzzle.id.zero?)
      reset = ResetButtonView.new(model.puzzle).render.element
      undo = UndoButtonView.new(model.puzzle).render.element
      hint = HintButtonView.new(model).render.element
      nexx = Element.new(:button).add_class('next').text('Next puzzle')
      nexx.prop(:disabled, model.puzzle.id == Puzzle.count - 1)
      Element.new << prev << reset << undo << hint << nexx
    end

    def render_hint_rules
      header = Element.new(:tr) << Element.new(:th).text('Hint Rules') << Element.new(:th).text('Auto-apply?')
      head = Element.new(:thead) << header
      rules = model.hint_rules.map { |rule| HintRuleView.new(rule).render.element }
      body = Element.new(:tbody).append(rules)
      Element.new(:table).add_class(:hint_rules) << head << body
    end
  end
end
