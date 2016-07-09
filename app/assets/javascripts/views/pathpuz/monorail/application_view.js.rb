require 'vienna'

module Monorail
  class ApplicationView < Vienna::View
    attr_accessor :model, :puzzle

    def initialize(model)
      self.model = model

      model.add_observer(:puzzle) do |puzzle|
        # TODO: move to Application#next_puzzle!
        # TODO: remove old handler from previous puzzle?
        puzzle.on(:lines_changed) { puzzle.hint! if model.autohint }
        render
      end

      model.add_observer(:autohint) do |autohint|
        @autohint_checkbox.prop('checked', autohint)
      end
    end

    def render
      instructions = Element.new(:p).text('Build a monorail loop that visits every dot.')
      self.puzzle = PuzzleView.new(model.puzzle)

      @autohint_checkbox = Element.new(:input).attr(:type, 'checkbox').prop('checked', model.autohint)
      @autohint_checkbox.on(:change) do
        model.autohint = @autohint_checkbox.is(':checked')
      end
      autohint_label = Element.new(:label).text('Auto-hint').prepend(@autohint_checkbox)
      autohint = Element.new(:div).append(autohint_label)
      autohint.class_name = :autohint
      
      buttons = Element.new(:div)

      hint_button = Element.new(:button).text('Hint')
      hint_button.on(:click) { model.puzzle.hint! }

      next_button = Element.new(:button).text('Next puzzle')
      next_button.on(:click) do
        # TODO: move to Application
        model.router.navigate(model.puzzle.id + 1)
      end

      buttons.append(hint_button).append(next_button)

      element.empty
      element.append(instructions)
      element.append(puzzle.render.element)
      element.append(autohint)
      element.append(buttons)

      self
    end
  end
end
