require 'rails/engine/commands_tasks'

module Pathpuz
  class CommandsTasks < Rails::Engine::CommandsTasks
    def test
      if ARGV.empty?
        run_rake_task('test:javascripts')
        ARGV.shift
      end
      super
    end
  end
end
