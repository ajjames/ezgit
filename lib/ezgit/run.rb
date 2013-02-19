if RUBY_PLATFORM =~ /mswin/ or RUBY_PLATFORM =~ /mingw32/
  require 'ezgit/string_no_color'
else
  require 'ezgit/string'
end

require 'ezgit/trollop'
require 'ezgit/commands'
require 'ezgit/ezgit_command'

$commands = Commands.new
$commands.read
$commands.options = EzgitCommand::options($commands.names, $commands.help_list)
$commands.process