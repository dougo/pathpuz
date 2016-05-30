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

  # TODO: loosen the requirements
  s.add_dependency 'rails', '4.2.6'
  s.add_dependency 'sass-rails', '~> 5.0'
  s.add_dependency 'uglifier', '2.5.3'
  s.add_dependency 'turbolinks', '2.5.2'

  s.add_dependency 'opal-rails', '~> 0.8.1'
  s.add_dependency 'haml-rails', '~> 0.6.0'
  s.add_dependency 'opal-haml', '~> 0.2.0'
  s.add_dependency 'opal-vienna'

  # TODO: remove these
  s.add_dependency 'html2haml', '~> 1.0.1'
  s.add_dependency 'haml', '4.1.0.beta.1'
  s.add_dependency 'sexp_processor', '4.4.4'

  s.add_development_dependency 'sqlite3'
end
