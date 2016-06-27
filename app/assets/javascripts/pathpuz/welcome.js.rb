require 'opal-jquery'

Document.ready? do
  model = Monorail::Puzzle.find(0)
  view = Monorail::PuzzleView.new(model)
  Element['#puzzle'] << view.element
  view.render
end
