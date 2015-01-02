require 'vienna/template_view'

class MonorailView < Vienna::TemplateView
  on :click, :line do |evt|
    line = evt.target
    if line[:stroke] == :transparent
      line[:stroke] = :black
    else
      line[:stroke] = :transparent
    end
  end
end
