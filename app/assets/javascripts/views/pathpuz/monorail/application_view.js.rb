require 'vienna'

module Monorail
  class ApplicationView < Vienna::View
    attr_accessor :model, :router, :puzzle

    def initialize(model)
      self.model = model

      model.add_observer(:puzzle) do |puzzle|
        # TODO: move to Application#next_puzzle!
        # TODO: remove old handler from previous puzzle?
        puzzle.on(:lines_changed) { puzzle.hint! if autohint? }
        render
      end

      # TODO: move this to Application
      self.router = Vienna::Router.new
      router.route(':id') { |params| self.model_id = params[:id].to_i }
      router.route('/') { self.model_id = 0 }
    end

    def render
      instructions = Element.new(:p).text('Build a monorail loop that visits every dot.')
      self.puzzle = PuzzleView.new(model.puzzle)

      @autohint_checkbox = Element.new(:input).attr(:type, 'checkbox')
      autohint_label = Element.new(:label).text('Auto-hint').prepend(@autohint_checkbox)
      autohint = Element.new(:div).append(autohint_label)
      autohint.class_name = :autohint
      
      buttons = Element.new(:div)

      hint_button = Element.new(:button).text('Hint')
      hint_button.on(:click) { model.puzzle.hint! }

      next_button = Element.new(:button).text('Next puzzle')
      next_button.on(:click) do
        # TODO: move to Application
        router.navigate(model.puzzle.id + 1)
      end

      buttons.append(hint_button).append(next_button)

      element.empty
      element.append(instructions)
      element.append(puzzle.render.element)
      element.append(autohint)
      element.append(buttons)
    end

    private

    # TODO: move to Application?
    def model_id=(id)
      self.model.puzzle = Puzzle.find(id)
    end

    def autohint?
      @autohint_checkbox.prop(:checked)
    end
  end
end
