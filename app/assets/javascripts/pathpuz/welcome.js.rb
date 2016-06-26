require 'opal-jquery'

Document.ready? do
  model = Monorail::Puzzle.of_size(2)
  view = Monorail::PuzzleView.new(model)
  Element['#puzzle'] << view.element
  view.render
end
