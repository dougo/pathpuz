require 'opal-jquery'

def welcome
  return unless root = Element.id(:puzzle)
  model = Monorail::Application.new
  view = Monorail::ApplicationView.new(model)
  root << view.element
  view.render
end

Document.ready? &:welcome
