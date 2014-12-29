require 'opal/minitest/rake_task'

namespace :test do
  Rails::TestTask.new(:features => 'test:prepare') do |t|
    t.pattern = 'test/features/**/*_test.rb'
  end

  # Add all gem asset paths to Opal, so that require works in tests like it does in the Rails app.
  $LOAD_PATH.each do |p|
    p = Pathname.new(p).join('..')
    %w(lib app vendor).each { |d| Opal.append_path(p.join(d, 'assets/javascripts').to_s) }
  end

  Opal::Minitest::RakeTask.new(:name => :javascripts, :port => 2839,
                               :requires_glob => 'test/javascripts/{test_helper,**/*_test}.js.rb')
  Rake::Task['test:run'].enhance ['test:javascripts']
end
