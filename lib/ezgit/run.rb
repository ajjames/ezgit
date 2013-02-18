if RUBY_PLATFORM =~ /mswin/
  require 'ezgit/string_no_color'
else
  require 'ezgit/string'
end

require 'ezgit/trollop'
require 'ezgit/commands'
require 'ezgit/ez_command'

$commands = Commands.new
$commands.read
$commands.options = EzCommand::options($commands.names, $commands.help_list)
$commands.process