require 'pathpuz/welcome'

class WelcomeTest < Minitest::Test
  attr_accessor :el

  def setup
    self.el = Element.id(:puzzle) || Element.new.send(:id=, :puzzle).append_to(Document.body)
  end

  test 'welcome' do
    welcome
    refute_empty el.children
  end
end
