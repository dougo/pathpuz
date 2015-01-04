require 'opal-jquery'

class SVGElement < Element
  NS = 'http://www.w3.org/2000/svg'

  def self.new(tag)
    el = `$(document.createElementNS(#{NS}, tag))`
    el[:xmlns] = NS if tag == :svg
    el
  end
end
