require 'vienna'

module Monorail
  class PuzzleView < Vienna::View
    attr_accessor :model, :router, :svg

    def initialize(model)
      self.model = model
      self.router = Vienna::Router.new
      router.route(':id') { |params| self.model_id = params[:id].to_i }
      router.route('/') { self.model_id = 0 }
    end

    def render
      instructions = Element.new(:p).text('Build a monorail loop that visits every dot.')
      self.svg = SVGView.new(model)

      @autohint_checkbox = Element.new(:input).attr(:type, 'checkbox')
      autohint_label = Element.new(:label).text('Auto-hint').prepend(@autohint_checkbox)
      autohint = Element.new(:div).append(autohint_label)
      autohint.class_name = :autohint
      
      buttons = Element.new(:div)

      hint_button = Element.new(:button).text('Hint')
      hint_button.on(:click) { hint! }

      next_button = Element.new(:button).text('Next puzzle')
      next_button.on(:click) do
        router.navigate(model.id + 1)
      end

      buttons.append(hint_button).append(next_button)

      element.empty
      element.append(instructions)
      element.append(svg.render.element)
      element.append(autohint)
      element.append(buttons)
    end

    def model=(model)
      prev_model = self.model
      @model = model
      # TODO: remove old handler from prev_model?
      model.on(:lines_changed) { hint! if autohint? }
      render if prev_model
    end

    private

    def model_id=(id)
      self.model = Puzzle.find(id)
    end

    def autohint?
      @autohint_checkbox.prop(:checked)
    end

    def hint!
      dot = model.find_completable_dot
      dot.complete! if dot
    end
  end
end
