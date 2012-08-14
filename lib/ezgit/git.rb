require 'open3'
require 'ezgit/string'

class Git

  def initialize(global_options)
    @dry_run = global_options[:dry_run] ? '-n' : ''
  end


  def log_graph(count = 5)
    puts ''
    puts "REPOSITORY TREE".white.bold + "(last #{count} commits)"
    puts `git log --graph --all --format=format:'%h %C(blue)(%cr)%C(reset) %C(green)%cn%C(reset) %C(white)%s%C(reset)%C(yellow)%d%C(reset)' --abbrev-commit --date=relative -n #{count}`
  end


  def branch
    puts ''
    #YOUR BRANCHES
    puts 'YOUR BRANCHES:'.bold
    out = `git branch`
    out.split("\n").each do |br|
      is_current = br.include?('*')
      br.gsub!(/\*?\s+/, '')
      br = "#{br} <-- CURRENT" if is_current
      puts "  #{br}".yellow
    end
    #REMOTE BRANCHES
    puts 'REMOTE BRANCHES:'.bold
    out = `git branch -r`
    out.split("\n").each do |br|
      puts '  ' + br.gsub(/ \*?\s+origin\//, '').yellow if not br.include?('origin/HEAD')
    end
  end


  def status
    puts ''
    puts 'CURRENT CHANGES:'.white.bold
    system('git status -s')
  end


  def reset_hard
    return if not @dry_run.empty?
    puts `git reset --hard`
  end


  def clean
    puts `git clean -df #{@dry_run}`
  end


  def clone(args)
    if args.count < 1 || args.count > 2
      puts 'invalid number of arguments. Requires a source. (Destination is optional.)'
      return
    end
    return if not @dry_run.empty?
    puts out = `git clone #{args.first} #{args[1]}`
    repo_name = args[1] || out.split('\'')[1]
    puts 'You have created a copy of ' + args.first.to_s.bold + ' in the ' + repo_name.bold + ' directory.' if $? == 0
  end


  def clean!
    puts `git  clean -dfx #{@dry_run}`
  end


  def checkout(opts, args)

  end


end