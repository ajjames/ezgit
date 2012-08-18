require 'open3'

class Git

  attr_reader :current_branch, :remote_branch, :all_branches, :all_uniq_branches
  NO_BRANCH = '(nobranch)'


  def initialize(global_options)
    @its_a_dry_run = global_options[:dry_run_flag]
    @dry_run_flag = @its_a_dry_run ? '-n' : ''
  end


  def current_branch
    if @current_branch.nil?
      remove_refs_regex = /.+\/(\w+)/
      out = `git symbolic-ref HEAD 2>&1`.match(remove_refs_regex)
      @current_branch = (out.nil?) ? NO_BRANCH : out[1].to_s
    end
    return @current_branch
  end


  def remote_branch(branch_name = nil)
    if @remote_branch.nil?
      @remote_branch = add_remote_to_branch(current_branch)
    end
    return @remote_branch
  end


  def add_remote_to_branch(branch_name)
    # Get remote name.  It may not be 'origin'
    origin = `git remote show`.gsub(/\s/, '')
    remote = "#{origin}/#{branch_name}"
    remote = all_branches.include?(remote) ? remote : ''
    return remote
  end


  def refresh_branches
    @all_branches = nil
    @all_uniq_branches = nil
  end


  def all_branches
    if @all_branches.nil?
      # create regexes to remove the refs, HEAD entry, spaces, *, etc
      strip_head_regx = /^.*\/HEAD -> .*$\n/
      strip_asterisks_and_spaces_regx = /[\* ]/
      strip_remotes_regex = /remotes\//
      git_a = `git branch -a --no-color`.gsub(strip_head_regx, '').gsub(strip_asterisks_and_spaces_regx, '').gsub(strip_remotes_regex, '')
      @all_branches = git_a.split("\n")
    end
    return @all_branches
  end


  def all_uniq_branches
    if @all_uniq_branches.nil?
      remove_refs_regx = /([\* ])|(.*\/)/
      @all_uniq_branches = []
      all_branches.each do |br|
        @all_uniq_branches << br.gsub(remove_refs_regx, '')
      end
      @all_uniq_branches.uniq!
      @all_uniq_branches.sort!
    end
    return @all_uniq_branches
  end


  def display_log_graph(count = 5, show_all = false)
    puts ''
    puts "REPOSITORY TREE".white.bold + "(last #{count} commits)"
    all = show_all ? '--all' : ''
    stdin, stdout, stderr = Open3.popen3("git log --graph #{all} --format=format:\"#{CYAN}%h #{CLEAR + CYAN}(%cr) #{CYAN}%cn #{CLEAR + WHITE}%s#{CYAN + BOLD}%d#{CLEAR}\" --abbrev-commit --date=relative -n #{count}")
    err = stderr.readlines
    return puts 'There is no history yet.'.cyan.bold if err.any?
    puts err.join('') + stdout.readlines.join('')
  end


  def display_branch_list_with_current
    puts ''
    puts '  BRANCHES:'.bold
    brs = []
    all_uniq_branches.each do |b|
      #add an indicator if it is the current branch
      b = b.eql?(current_branch) ? "#{b} <-- CURRENT".bold : b
      # output the list
      puts "  #{b}".cyan
    end
  end


  def info(opts=nil)
    puts '________________________________'
    $commands.git.display_log_graph
    $commands.git.display_branch_list_with_current
    $commands.git.display_current_changes(opts)
    $commands.git.display_sync_status
    puts '________________________________'
  end


  #returns :up_to_date/:no_remote/:rebase/:ahead/:behind, count
  def check_remote_status
    return :headless if current_branch == NO_BRANCH
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
    puts '  SYNC STATUS:'.white.bold
    stat, count = check_remote_status
    commit_s = (count == 1) ? 'commit' : 'commits'
    case stat
      when :ahead
        puts "  Your #{current_branch.bold + CYAN} branch is ahead of the remote by #{count} #{commit_s}.".cyan
        puts "  (Use 'ez pull' to update the remote.)".cyan
      when :behind
        puts "  Your #{current_branch.bold + YELLOW} branch is behind the remote by #{count} #{commit_s}.".yellow
        puts "  (Use 'ez pull' to get the new changes.)".yellow
      when :rebase
        puts "  Your #{current_branch} branch has diverged #{count} #{commit_s} from the remote.".red.bold
        puts "  (Use must use git directly to put them back in sync.)".red.bold
      when :no_remote
        puts "  Your #{current_branch.bold + CYAN} branch does not yet exist on the remote.".cyan
        puts "  (Use 'ez pull' to update the remote.)".cyan
      when :headless
        puts "  You are in a headless state (not on a branch)".red.bold
        puts "  (Use 'ez create <branch>' to create a branch at this commit,".red.bold
        puts "   or use 'ez switch <branch>' to switch to a branch.)".red.bold
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
    puts "  TO BE COMMITTED ON: #{current_branch}".white.bold
    has_changes, changes = check_local_changes(opts)
    puts "  No changes.".green unless has_changes
    changes.collect! { |line|
      line.sub!('!! ', CYAN + "  ignore  " + CLEAR)
      line.gsub!(/ U |U  /, RED + BOLD + "   MERGE  " + CLEAR)
      line.gsub!(/ D |D  /, RED + BOLD + "  Delete  " + CLEAR)
      line.gsub!(/.R |R. /, YELLOW + BOLD + "  Rename  " + CLEAR)
      line.gsub!(/A  |\?\? /, YELLOW + BOLD + "     Add  " + CLEAR)
      line.gsub!(/.M |M. /, YELLOW + BOLD + "  Change  " + CLEAR)
      line
    }
    puts changes.sort!
  end


  def clone(args)
    return puts 'invalid number of arguments. Requires a source. (Destination is optional.)' if args.count < 1 || args.count > 2
    return if @its_a_dry_run
    puts out = `git clone #{args.first} #{args[1]}`
    repo_name = args[1] || out.split('\'')[1]
    puts 'You have created a copy of ' + args.first.to_s.bold + ' in the ' + repo_name.bold + ' directory.' if $? == 0
  end


  def clean!(wipe_ignored, opts)
    x = wipe_ignored ? 'x' : ''
    stdin, stdout, stderr = Open3.popen3("git clean -dfn#{x}")
    out = stderr.readlines
    err = stdout.readlines.join('')
    puts err.red.bold unless opts[:force]
    return puts 'Nothing to clean.'.green if err.empty?
    return if @its_a_dry_run
    run_lambda_with_force_option(opts) do
      puts `git clean -df#{x} #{@dry_run}`
    end
  end


  def prompt_for_y_n
    begin
      system("stty raw -echo")
      input = STDIN.getc
    ensure
      system("stty -raw echo")
    end
    out = input.to_s.downcase.eql?('y')
    puts input.to_s
    return out
  end


  def run_lambda_with_force_option(opts)
    unless opts[:force]
      print 'proceed(y/n)? '.bold
      return unless prompt_for_y_n
    end
    yield
  end


  def reset_hard!(opts)
    return if @its_a_dry_run
    puts 'All changes in tracked files will be lost.'.red.bold unless opts[:force]
    run_lambda_with_force_option(opts) do
      puts `git reset --hard`
    end
  end


  def goto!(opts, args)
    return puts "Please specify a commit id.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a commit id.".yellow.bold if args.count > 1
    commit_id = args[0].to_s
    return puts "Would go to #{commit_id}" if @its_a_dry_run
    puts "About to go to #{commit_id}. All changes in tracked files will be lost.".red.bold unless opts[:force]
    run_lambda_with_force_option(opts) do
      puts `git reset --hard #{commit_id}`
    end
  end


  def create(opts, args)
    return puts "Please specify a branch name.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a branch name.".yellow.bold if args.count > 1
    branch_name = args[0].to_s
    return puts "Would create branch: #{branch_name}" if @its_a_dry_run
    `git checkout -b #{branch_name}`
    display_branch_list_with_current
    display_current_changes
  end


  def delete!(opts, args)
    return puts "Please specify a branch name.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a branch name.".yellow.bold if args.count > 1
    branch_name = args[0].to_s
    is_master = branch_name.eql?('master') || branch_name.eql?(add_remote_to_branch('master'))
    return puts "Cannot delete ".red + branch_name.red.bold + ".".red if is_master
    branches = []
    is_local = all_branches.include?(branch_name)
    branches << branch_name if is_local
    remote_name = add_remote_to_branch(branch_name)
    is_remote = all_branches.include?(remote_name)
    branches << remote_name if is_remote
    return puts "Cannot delete ".red + branch_name.red.bold + " while you are using it. Please switch to another branch and try again.".red if branches.include?(current_branch)
    return puts "Branch does not exist: ".red + branch_name.red.bold unless branches.any?
    return puts "Would completely delete branches: #{branches.join(',')}" if @its_a_dry_run
    print "  Are you sure you want to delete '#{branch_name}'(y/n)?".red.bold
    return unless run_lambda_with_force_option(opts) do
      puts `git push --delete #{remote_name.sub('/', ' ')}` if is_remote
      puts `git branch -D #{branch_name}` if is_local
      refresh_branches
      display_branch_list_with_current
    end
  end


#Three modes:
#  :switch  - switch if there are not changes. Otherwise halt!
#  :switch! - clobber all files before switching
#  :move    - move files with switch
  def switch!(opts, args)
    return puts "Please specify a branch name.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a branch name.".yellow.bold if args.count > 1
    branch_name = args[0].to_s
    return puts "Please specify a valid branch." unless all_uniq_branches.include?(branch_name)
    return puts "Already on branch: #{current_branch.bold}".green if current_branch.eql?(branch_name)
    has_changes, changes = check_local_changes
    #move files with switch
    if opts[:move]
      x = `git checkout #{branch_name}`
      return
    end
    #switch if there are not changes. Otherwise halt!
    if has_changes && opts[:switch]
      display_current_changes
      puts "  Cannot switch branches when you have unresolved changes".red
      puts "  Use ".red + "'ez switch! <branch>'".red.bold + " to abandon your changes and switch anyway,".red
      puts "  or use ".red + "'ez move <branch>'".red.bold + " to move your changes and switch.".red
      return
    end
    #clobber all files before switching
    #respect the -f option
    if has_changes && opts[:switch!]
      unless opts[:force]
        display_current_changes
        puts ''
        print "  WARNING: You may lose changes if you switch branches without committing.".red.bold
      end
      return unless run_lambda_with_force_option(opts) do
        opts[:force] = true
        x = `git clean -df`
        x = `git checkout -f #{branch_name}`
        return
      end
      x = `git clean -df`
    end
    x = `git checkout -f #{branch_name}`
  end


  def commit(args)
    return puts "Please specify a message.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a message.".yellow.bold if args.count > 1
    has_changes, changes = check_local_changes
    return puts "There are no changes to commit".yellow.bold unless has_changes
    commit_id = args[0].to_s
    puts `git add -A`
    puts `git commit -m "#{commit_id}"`
  end


  def fetch
    stdin, stdout, stderr = Open3.popen3("git fetch -p #{@dry_run_flag}")
    puts stderr.readlines.join('') + stdout.readlines.join('')
    refresh_branches
  end


  def pull
    fetch
    stat, count = check_remote_status
    case stat
      when :rebase
        if @its_a_dry_run
          puts 'would merge changes'
          display_sync_status
          return
        end
        puts `git rebase #{remote_branch}`
        #TODO: CONFLICT HANDLING?
        puts 'TODO: CONFLICT HANDLING?'
      when :behind
        if @its_a_dry_run
          puts "would reset branch to #{remote_branch}"
          display_sync_status
          return
        end
        puts `git reset --hard #{remote_branch}`
      when :headless
        puts '  You cannot pull unless you are on a branch.'.red.bold
        display_sync_status
        return
    end
    info
  end


  def push
    stat, count = check_remote_status
    if stat.eql?(:rebase) || stat.eql?(:behind)
      puts "  The remote has been updated since you began this sync.".yellow.bold
      puts "  Try running 'ez pull' again".yellow.bold
    elsif stat.eql?(:no_remote) || stat.eql?(:ahead)
      puts `git push -u #{remote_branch.sub('/', ' ')}`
    elsif stat.eql?(:headless)
      puts '  You cannot push unless you are on a branch.'.red.bold
    else
      #:up_to_date | :headless
    end
    info
  end


end