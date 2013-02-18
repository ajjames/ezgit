require 'ezgit/git'

class Commands

  attr_accessor :all, :symbols, :names, :help_list, :options, :git


  def initialize
    @all = []
    @symbols = []
    @names = []
    @help_list = ''
    @options = {}
  end


  def read
    commands_dir = File.expand_path "commands", File.dirname(__FILE__)
    files = Dir["#{commands_dir}/*.rb"]
    files.each do |command_file|
      require command_file
      current_symbol = @all.last[:name]
      @symbols << current_symbol
      @names << current_symbol.to_s
      @help_list << "\t#{@names.last.cyan.bold}\t#{@all.last[:help].to_s.bold}\n"
    end
  end


  def process
    @git = Git.new(@options)
    @cmd = ARGV.shift
    matched = false
    @all.each do |current|
      if current[:name].to_s.eql? @cmd
        matched = true
        @cmd_opts = Trollop::options do
          usage = current[:usage]
          usage ||= "ezgit #{current[:name].to_s} [<options>]"
          banner <<-HELP_DESCRIPTION
command: ezgit #{current[:name].to_s}\n
#{current[:help].to_s}

Usage:
        #{usage}

   options are:
HELP_DESCRIPTION

          current[:options].each do |cmd_opt|
            sym = cmd_opt[0]
            info = cmd_opt[1]
            flags = cmd_opt[2]
            opt sym, info, flags
          end
        end
        current[:action].call(@cmd_opts, ARGV)
        break
      end
    end
    Trollop::die "unknown subcommand #{@cmd.inspect}" if not matched
    if $commands.options[:debug]
      puts "Global options: #{$commands.options.inspect}"
      puts "Subcommand: #{@cmd.inspect}"
      puts "Subcommand options: #{@cmd_opts.inspect}"
      puts "Remaining arguments: #{ARGV.inspect}"
    end
  end


end
