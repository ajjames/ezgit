require 'open3'

class Git

  def initialize(global_options)
    @dry_run = global_options[:dry_run] ? '-n' : ''
  end


  def log_graph(count = 5)
    puts ''
    puts "REPOSITORY TREE".white.bold + "(last #{count} commits)"
    puts `git log --graph --all --format=format:"#{GREEN + BOLD}%h #{CLEAR + CYAN}(%cr) #{CYAN + BOLD}%cn #{CLEAR + WHITE}%s#{YELLOW}%d#{CLEAR}" --abbrev-commit --date=relative -n #{count}`
  end


  def branch
    puts ''
    puts 'BRANCHES:'.bold
    # Get remote name.  It may not be 'origin'
    origin = `git remote show`.gsub(/\s/, '')
    # create possible regexes to remove the HEAD entry
    strip_head = "  remotes\/#{origin}\/HEAD -> #{origin}\/master"
    strip_head_break = "#{strip_head}\n"
    break_strip_head = "\n#{strip_head}"
    # get all branches from git, remove the HEAD entry, and normalize (strip 'remotes/origin/', & strip spaces)
    git_a = `git branch -a --no-color`.gsub(/#{break_strip_head}/, '').gsub(/#{strip_head_break}/, '').gsub(/#{strip_head}/, '').gsub(/ /, '').gsub(/remotes\/#{origin}\//, '')
    # grab the current branch name
    current_branch = git_a.match(/\*(.+)\n/)[1]
    # strip the current branch indicator and split into an array
    all_branches = git_a.gsub(/\*/, '').split("\n")
    all_branches.uniq!
    all_branches.sort!
    #add an indicator if it is the current branch
    all_branches.collect! { |b| b.eql?(current_branch) ? "#{b} <-- CURRENT".bold : b }
    # output the list
    all_branches.each do |br|
      puts "  #{br}".yellow
    end
  end


  def status(opts)
    ignored = opts[:ignored] ? '--ignored' : ''
    puts ''
    puts 'CURRENT CHANGES:'.white.bold
    # system('git status -bs')
    stdin, stdout, stderr = Open3.popen3("git status --porcelain #{ignored}")
    changes = stdout.readlines
    puts "  No changes.".green unless changes.any?
    changes.collect! { |line|
      line.sub!('!! ', CYAN +                "    ignore  " + CLEAR)
      line.gsub!(/ U |U  / , YELLOW + BOLD + "     merge  " + CLEAR)
      line.gsub!(/ D |D  / , RED + BOLD +    "    delete  " + CLEAR)
      line.gsub!(/.R |R. / , RED + BOLD +    "    rename  " + CLEAR)
      line.gsub!(/A  |\?\? / , CYAN + BOLD + "       add  " + CLEAR)
      line.gsub!(/.M |M. / , RED + BOLD +    "    change  " + CLEAR)
      line
    }
    puts changes.sort!
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