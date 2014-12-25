require 'opal-jquery'

Document.ready? do
  view = MonorailView.new
  Element['#puzzle'] << view.element
  view.render
end
