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
    #COLLECT REMOTE BRANCHES
    puts 'BRANCHES:'.bold
    branches = []
    remote = `git branch -r`.split("\n")
    remote.each do |br|
      branches << br.gsub(/ \*?\s+origin\//, '') unless br.include?('origin/HEAD')
    end
    #COLLECT LOCAL BRANCHES
    local = `git branch`
    #Combine the list and mark the current branch
    local.split("\n").each do |br|
      is_current = br.include?('*')
      br.gsub!(/\*?\s+/, '')
      if is_current
        #add an indicator if it is the current branch
        branches.collect! { |b|
          b.eql?(br) ? "#{br} <-- CURRENT".bold : b
        }
      else
        branches << br
      end
    end
    branches.select{|br| branches.count(br) == 1}.each do |br|
      puts "  #{br}".yellow
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