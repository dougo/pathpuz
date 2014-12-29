require 'vienna/template_view'
require 'templates/monorail'

class MonorailView < Vienna::TemplateView
  template :monorail

  def tag_name
    'p'
  end
end
