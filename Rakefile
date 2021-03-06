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
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'


load 'rails/tasks/statistics.rake'



require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = false
end


task default: :test


require 'opal/minitest/rake_task'

namespace :test do
  task :features => 'app:test:prepare' do
    $: << 'test'
    Minitest.rake_run(['test/features'])
  end

  # Add all gem asset paths to Opal, so that require works in tests like it does in the Rails app.
  $LOAD_PATH.each do |p|
    p = Pathname.new(p).join('..')
    %w(lib app vendor).each { |d| Opal.append_path(p.join(d, 'assets/javascripts').to_s) }
  end

  Opal::Minitest::RakeTask.new(:name => :javascripts, :port => 2845,
                               :requires_glob => 'test/javascripts/{test_helper,**/*_test}.js.rb')
  Rake::Task[:test].enhance ['test:javascripts']
end


# Add directories to 'rake stats'
task :stats => 'pathpuz:stats'
namespace :pathpuz do
  task :stats do
    require 'rails/code_statistics'
    ::STATS_DIRECTORIES << ['Feature Tests', 'test/features']
    ::STATS_DIRECTORIES << ['Javascript Tests', 'test/javascripts']
    CodeStatistics::TEST_TYPES << 'Feature Tests' << 'Javascript Tests'
  end
end
