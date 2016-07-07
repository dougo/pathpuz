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
      buttons = Element.new(:div)

      hint_button = Element.new(:button).text('Hint')
      hint_button.on(:click) do
        dot = model.find_completable_dot
        dot.complete! if dot
      end

      next_button = Element.new(:button).text('Next puzzle')
      next_button.on(:click) do
        router.navigate(model.id + 1)
      end

      buttons.append(hint_button).append(next_button)

      element.empty
      element.append(instructions)
      element.append(svg.render.element)
      element.append(buttons)
    end

    def model=(model)
      prev_model = self.model
      @model = model
      render if prev_model
    end

    private

    def model_id=(id)
      self.model = Puzzle.find(id)
    end
  end
end
