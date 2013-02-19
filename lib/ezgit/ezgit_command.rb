require 'ezgit/version'

class EzgitCommand
	def self.options(subcommand_names, subcommand_help_list)
		return Trollop::options do
		  version Ezgit::VERSION
		  banner <<-HELP_DESCRIPTION
EZGit is a simple interface for working with git repositories.

Usage:
        ezgit [<options>] <commands>
              - or -
        ez [<options>] <commands>
              - or -
        eg [<options>] <commands>
              - or -
        gt [<options>] <commands>

  commands are:
#{subcommand_help_list}
   options are:
HELP_DESCRIPTION
		  opt :dry_run, 'Makes all commands passive.', short: '-n'
      opt :force, 'Forces all prompting off. Use ! at end of command name to do the same.', short: '-f', default: false
		  opt :debug, 'Shows command level debug info.', short: '-d'
		  stop_on subcommand_names
		end
	end
end