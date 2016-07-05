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
      next_button = Element.new(:div).append(Element.new(:button).text('Next puzzle'))

      element.empty
      element.append(instructions)
      element.append(svg.render.element)
      element.append(next_button)
    end

    on :click, :button do
      router.navigate(model.id + 1)
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
