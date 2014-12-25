require 'vienna'

class MonorailView < Vienna::View
  def tag_name
    'p'
  end

  def render
    element.html = 'Soon there will be a puzzle here.'
  end
end
