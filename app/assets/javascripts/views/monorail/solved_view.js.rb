require 'vienna'

module Monorail
  class SolvedView < Vienna::View
    attr_accessor :model

    tag_name :p
    class_name :solved

    def initialize(model)
      self.model = model
      model.on(:solved) { render }
    end

    def render
      element.text = model.solved? ? 'Solved!' : ''
      self
    end
  end
end
