require 'opal-jquery'

Document.ready? do
  model = Monorail::Application.new
  view = Monorail::ApplicationView.new(model)
  Element['#puzzle'] << view.element
  view.render
end
