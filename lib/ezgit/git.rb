require 'open3'

class Git

  attr_reader :current_branch, :remote_branch, :all_branches

  def initialize(global_options)
    @dry_run = global_options[:dry_run] ? '-n' : ''
  end


  def current_branch
    if @current_branch.nil?
      rgx = /.+\/(\w+)/
      @current_branch = `git symbolic-ref HEAD`.match(rgx)[1]
    end
    return @current_branch
  end


  def remote_branch
    if @remote_branch.nil?
      # Get remote name.  It may not be 'origin'
      origin = `git remote show`.gsub(/\s/, '')
      @remote_branch = "#{origin}/#{current_branch}"
      @remote_branch = all_branches.include?("remotes/#{remote_branch}") ? remote_branch : ''
    end
    return @remote_branch
  end


  def all_branches
    if @all_branches.nil?
      # create regexes to remove the refs, HEAD entry, spaces, *, etc
      strip_head_regx = /^.*\/HEAD -> .*$\n/
      strip_asterisks_and_spaces_regx = /[\* ]/
      git_a = `git branch -a --no-color`.gsub(strip_head_regx, '').gsub(strip_asterisks_and_spaces_regx, '')
      @all_branches = git_a.split("\n")
    end
    return @all_branches
  end


  def log_graph(count = 5)
    puts ''
    puts "REPOSITORY TREE".white.bold + "(last #{count} commits)"
    puts `git log --graph --all --format=format:"#{GREEN + BOLD}%h #{CLEAR + CYAN}(%cr) #{CYAN + BOLD}%cn #{CLEAR + WHITE}%s#{YELLOW}%d#{CLEAR}" --abbrev-commit --date=relative -n #{count}`
  end


  def branch_list_with_current
    puts ''
    puts 'BRANCHES:'.bold
    remove_refs_regx = /([\* ])|(.*\/)/
    brs = []
    all_branches.each do |br|
      b = br.gsub(remove_refs_regx, '')
      #add an indicator if it is the current branch
      b = b.eql?(current_branch) ? "#{b} <-- CURRENT".bold : b
      brs << b
    end
    brs.uniq!
    brs.sort!
    # output the list
    brs.each do |br|
      puts "  #{br}".yellow
    end
  end


  #returns :up_to_date/:no_remote/:rebase/:ahead/:behind, count
  def check_remote_status
    ahead_count_rgx = /.*ahead.(\d+)/
    behind_count_rgx = /.*behind.(\d+)/
    stdin, stdout, stderr = Open3.popen3('git status -bs')
    stat = stdout.readlines[0]
    ahead_match = stat.match(ahead_count_rgx)
    ahead_count = (ahead_match.nil?) ? '0' : ahead_match[1]
    behind_match = stat.match(behind_count_rgx)
    behind_count = (behind_match.nil?) ? '0' : behind_match[1]
    case
      when ahead_count > '0' && behind_count == '0'
        return :ahead, ahead_count
      when ahead_count == '0' && behind_count > '0'
        return :behind, behind_count
      when ahead_count > '0' && behind_count > '0'
        return :rebase, '0'
      else
        return :no_remote, '0' if remote_branch.empty?
        return :up_to_date, '0'
    end
  end


  def sync_status
    puts ''
    puts 'SYNC STATUS:'.white.bold
    stat, count = check_remote_status
    commit_s = (count == 1) ? 'commit' : 'commits'
    case stat
      when :ahead
        puts "  Your #{current_branch.bold + CYAN} branch is ahead of the remote by #{count} #{commit_s}.".cyan
        puts "    Use 'ez push' to update the remote.".cyan
      when :behind
        puts "  Your #{current_branch.bold} branch is behind the remote by #{count} #{commit_s}.".yellow
        puts "    Use 'ez pull' to get the new changes.".yellow
      when :rebase
        puts "  Your #{current_branch} branch has diverged #{count} #{commit_s} from the remote.".red.bold
        puts "    Use must use git directly to put them back in sync.".red.bold
      when :no_remote
        puts "  Your #{current_branch.bold + CYAN} branch does not yet exist on the remote.".cyan
        puts "    Use 'ez push' to update the remote.".cyan
      else
        puts "   Your #{current_branch.bold + GREEN} branch is in sync with the remote.".green
        puts "    Use 'ez pull' to ensure it stays in sync.".green
    end
  end


  def status(opts)
    ignored = opts[:ignored] ? '--ignored' : ''
    puts ''
    puts 'CURRENT CHANGES:'.white.bold
    stdin, stdout, stderr = Open3.popen3("git status --untracked-files=all --porcelain #{ignored}")
    changes = stdout.readlines
    puts "  No changes.".green unless changes.any?
    changes.collect! { |line|
      line.sub!('!! ', CYAN + "  ignore  " + CLEAR)
      line.gsub!(/ U |U  /, YELLOW + BOLD + "   merge  " + CLEAR)
      line.gsub!(/ D |D  /, RED + BOLD + "  delete  " + CLEAR)
      line.gsub!(/.R |R. /, RED + BOLD + "  rename  " + CLEAR)
      line.gsub!(/A  |\?\? /, CYAN + BOLD + "     add  " + CLEAR)
      line.gsub!(/.M |M. /, RED + BOLD + "  change  " + CLEAR)
      line
    }
    puts changes.sort!
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


  def clean
    puts `git clean -df #{@dry_run}`
  end


  def clean!
    puts `git  clean -dfxn`
    return unless @dry_run.empty?
    print 'proceed(y/n)? '.bold
    begin
      system("stty raw -echo")
      input = STDIN.getc
    ensure
      system("stty -raw echo")
    end
    return unless input.to_s.downcase.eql?('y')
    puts input.to_s
    reset_hard
    puts `git  clean -dfx #{@dry_run}`
  end


  def reset_hard
    return if not @dry_run.empty?
    puts `git reset --hard`
  end


  def checkout(opts, args)

  end


end