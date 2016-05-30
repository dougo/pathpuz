require 'opal-jquery'

Document.ready? do
  model = Monorail::Puzzle.new
  view = Monorail::PuzzleView.new(model)
  Element['#puzzle'] << view.element
  view.render
end
