require 'vienna'

module Monorail
  class UndoButtonView < Vienna::View
    attr_accessor :model

    tag_name :button

    def initialize(model)
      @model = model
      model.on(:lines_changed) { render }
      model.on(:undone) { render }
    end

    def render
      element.text('Undo').prop(:disabled, !model.can_undo?)
      self
    end

    on(:click) { model.undo! }
  end
end
