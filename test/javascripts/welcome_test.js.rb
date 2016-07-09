require 'pathpuz/welcome'

class WelcomeTest < Minitest::Test
  attr_accessor :el

  def setup
    self.el = Element.new(:div)
    el.id = :puzzle
    Document.body << el
  end

  test 'welcome' do
    welcome
    refute_empty el.children
  end
end
