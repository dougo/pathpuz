require 'vienna'

module Monorail
  class SolvedView < Vienna::View
    attr_accessor :model

    tag_name :p
    class_name :solved

    def initialize(model)
      self.model = model
      # TODO: have the model send a single solved event
      model.lines.each do |line|
        line.add_observer(:present?) { render }
      end
    end

    def render
      element.text = model.lines.all?(&:present?) ? 'Solved!' : ''
      self
    end
  end
end
