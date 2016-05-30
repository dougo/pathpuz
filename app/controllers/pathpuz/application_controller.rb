class Pathpuz::ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Because this engine is isolated, helpers from gems are not automatically included into the views.
  # http://api.rubyonrails.org/classes/Rails/Engine.html#class-Rails::Engine-label-Isolated+Engine
  # But OpalHelper (from opal-rails) is what causes the code in application.js.rb to actually run.
  helper OpalHelper
end
