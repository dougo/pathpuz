require 'opal-jquery'

def welcome
  return unless Element.id(:puzzle)
  model = Monorail::Application.new
  Monorail::ApplicationView.new(model).render
end

Document.ready? &:welcome
