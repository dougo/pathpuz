require 'opal-jquery'

Document.ready? do
  model = Monorail::Puzzle.find(0)
  view = Monorail::ApplicationView.new(model)
  Element['#puzzle'] << view.element
  view.render
end
