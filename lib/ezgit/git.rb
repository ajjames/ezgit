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


  def display_log_graph(count = 5)
    puts ''
    puts "REPOSITORY TREE".white.bold + "(last #{count} commits)"
    puts `git log --graph --all --format=format:"#{CYAN}%h #{CLEAR + CYAN}(%cr) #{CYAN}%cn #{CLEAR + WHITE}%s#{CYAN + BOLD}%d#{CLEAR}" --abbrev-commit --date=relative -n #{count}`
  end


  def display_branch_list_with_current
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
      puts "  #{br}".cyan
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


  def display_sync_status
    puts ''
    puts 'SYNC STATUS:'.white.bold
    stat, count = check_remote_status
    commit_s = (count == 1) ? 'commit' : 'commits'
    case stat
      when :ahead
        puts "  Your #{current_branch.bold + CYAN} branch is ahead of the remote by #{count} #{commit_s}.".cyan
        puts "  (Use 'ez push' to update the remote.)".cyan
      when :behind
        puts "  Your #{current_branch.bold + YELLOW} branch is behind the remote by #{count} #{commit_s}.".yellow
        puts "  (Use 'ez pull' to get the new changes.)".yellow
      when :rebase
        puts "  Your #{current_branch} branch has diverged #{count} #{commit_s} from the remote.".red.bold
        puts "  (Use must use git directly to put them back in sync.)".red.bold
      when :no_remote
        puts "  Your #{current_branch.bold + CYAN} branch does not yet exist on the remote.".cyan
        puts "  (Use 'ez push' to update the remote.)".cyan
      else
        puts "  Your #{current_branch.bold + GREEN} branch is in sync with the remote.".green
        puts "  (Use 'ez pull' to ensure it stays in sync.)".green
    end
  end


  #returns (bool has_changes?, Array changes)
  def check_local_changes(opts = nil)
    ignored = (opts.nil? || opts[:ignored] == false) ? '' : '--ignored'
    stdin, stdout, stderr = Open3.popen3("git status --untracked-files=all --porcelain #{ignored}")
    changes = stdout.readlines
    return changes.any?, changes
  end


  def display_current_changes(opts = nil)
    puts ''
    puts 'CHANGES TO BE COMMITTED:'.white.bold
    has_changes, changes = check_local_changes(opts)
    puts "  No changes.".green unless has_changes
    changes.collect! { |line|
      line.sub!('!! ', CYAN +                 "  ignore  " + CLEAR)
      line.gsub!(/ U |U  /, RED + BOLD +      "   MERGE  " + CLEAR)
      line.gsub!(/ D |D  /, RED + BOLD +      "  Delete  " + CLEAR)
      line.gsub!(/.R |R. /, YELLOW + BOLD +   "  Rename  " + CLEAR)
      line.gsub!(/A  |\?\? /, YELLOW + BOLD + "     Add  " + CLEAR)
      line.gsub!(/.M |M. /, YELLOW + BOLD +   "  Change  " + CLEAR)
      line
    }
    puts changes.sort!
  end


  def clone(args)
    return puts 'invalid number of arguments. Requires a source. (Destination is optional.)' if args.count < 1 || args.count > 2
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


  def checkout(args)
    return puts "Please specify a branch name.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a branch name.".yellow.bold if args.count > 1
    has_changes, changes = check_local_changes
    if has_changes
      puts "Cannot switch branches when you have unresolved changes".yellow.bold
      display_current_changes
      return
    end
    puts `git checkout -f #{args[0]}`
  end


  def commit(args)
    return puts "Please specify a message.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a message.".yellow.bold if args.count > 1
    has_changes, changes = check_local_changes
    return puts "There are no changes to commit".yellow.bold unless has_changes
    puts `git add -A`
    puts `git commit -m "#{args[0]}"`
    display_log_graph
    display_current_changes
    display_sync_status
  end


  def pull
    has_changes, changes = check_local_changes
    if has_changes
      puts "Cannot pull when you have unresolved changes".yellow.bold
      display_current_changes
      return
    end
    `git fetch -p #{@dry_run}`
    stat, count = check_remote_status
    case stat
      when :rebase
        unless @dry_run.empty?
          puts 'would merge changes'
          display_sync_status
          return
        end
        puts `git rebase #{remote_branch}`
        #TODO: CONFLICT HANDLING?
        puts 'TODO: CONFLICT HANDLING?'
        display_log_graph
        display_sync_status
      when :behind
        unless @dry_run.empty?
          puts "would branch to #{remote_branch}"
          display_sync_status
          return
        end
        puts `git reset --hard #{remote_branch}`
        display_log_graph
        display_sync_status
      else
        display_sync_status
    end
  end


end