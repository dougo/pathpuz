require 'opal/minitest/rake_task'

namespace :test do
  Rails::TestTask.new(:features => 'test:prepare') do |t|
    t.pattern = 'test/features/**/*_test.rb'
  end

  Opal.append_path 'app/assets/javascripts'

  Opal::Minitest::RakeTask.new(:name => :javascripts, :port => 2839,
                               :requires_glob => 'test/javascripts/{test_helper,**/*_test}.js.rb')
  Rake::Task['test:run'].enhance ['test:javascripts']
end
