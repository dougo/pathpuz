$:.push File.expand_path("../lib", __FILE__)

require "pathpuz/version"

Gem::Specification.new do |s|
  s.name        = "pathpuz"
  s.version     = Pathpuz::VERSION
  s.authors     = ["Doug Orleans"]
  s.email       = ["dougorleans@gmail.com"]
  s.homepage    = "http://github.com/dougo/pathpuz"
  s.summary     = "Path-based logic puzzles."
  s.description = "Play path-based logic puzzles (like Monorail, Alcazar, Slitherlink) in a web browser."
  s.license     = "AGPL 3"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 5.0'
  s.add_dependency 'sass-rails'
  s.add_dependency 'uglifier'

  s.add_dependency 'opal-rails'
  s.add_dependency 'haml-rails'
  s.add_dependency 'opal-haml'
  s.add_dependency 'opal-vienna'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'minitest-rails-capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'phantomjs'
end
