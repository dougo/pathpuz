require 'pathpuz/commands_tasks'

ARGV << '--help' if ARGV.empty?

aliases = {
  "g" => "generate",
  "d" => "destroy",
  "t" => "test"
}

command = ARGV.shift
command = aliases[command] || command

Pathpuz::CommandsTasks.new(ARGV).run_command!(command)
