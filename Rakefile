begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Pathpuz'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'


load 'rails/tasks/statistics.rake'



Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end


task default: :test


require 'opal/minitest/rake_task'

namespace :test do
  Rails::TestTask.new(:features) do |t|
    t.pattern = 'test/features/**/*_test.rb'
  end

  # Add all gem asset paths to Opal, so that require works in tests like it does in the Rails app.
  $LOAD_PATH.each do |p|
    p = Pathname.new(p).join('..')
    %w(lib app vendor).each { |d| Opal.append_path(p.join(d, 'assets/javascripts').to_s) }
  end

  Opal::Minitest::RakeTask.new(:name => :javascripts, :port => 2845,
                               :requires_glob => 'test/javascripts/{test_helper,**/*_test}.js.rb')
  Rake::Task['test'].enhance ['test:javascripts']
end
