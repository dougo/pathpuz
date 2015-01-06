require 'opal-jquery'

Document.ready? do
  view = Monorail::PuzzleView.new
  Element['#puzzle'] << view.element
  view.render
end
