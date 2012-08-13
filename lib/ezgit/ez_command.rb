require 'ezgit/version'

class EzCommand
	def self.options(subcommand_names, subcommand_help_list)
		return Trollop::options do
		  version Ezgit::VERSION
		  banner <<-HELP_DESCRIPTION
Ezgit `ez` is a simplified command interface for working with git repositories.

Usage:
        ez [options] [commands]

  [commands] are:
#{subcommand_help_list}
   [options] are:
HELP_DESCRIPTION
		  opt :dry_run, "Don't actually do anything", :short => "-n"
		  stop_on subcommand_names
		end
	end
end