require 'open3'

class Git

  attr_reader :debug, :no_prompt, :dry_run, :dry_run_flag, :current_branch, :remote_branch, :all_branches, :all_uniq_branches
  attr_accessor :dry_run, :ignored
  NO_BRANCH = '(nobranch)'

  def initialize(dry_run, force, ignored, debug)
    self.dry_run = dry_run
    @no_prompt = force
    @debug = debug
    self.ignored = ignored
  end


  def dry_run=(dry_run)
    @dry_run = dry_run
    @dry_run_flag = @dry_run ? '-n' : ''
  end


  def ignored=(ignored)
    @ignored = ignored
    @ignored_flag = @ignored ? '--ignored' : ''
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
    puts "REPOSITORY TREE".bold + "(last #{count} commits)"
    all = show_all ? '--all' : ''
    stdin, stdout, stderr = Open3.popen3("git log --graph #{all} --format=format:\"#{CYAN}%h #{CLEAR + CYAN}(%cr) #{CYAN}%cn #{CLEAR}%s#{CYAN + BOLD}%d#{CLEAR}\" --abbrev-commit --date=relative -n #{count}")
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


  #returns (bool has_changes?, Array changes)
  def check_local_changes(opts = nil)
    stdin, stdout, stderr = Open3.popen3("git status --untracked-files=all --porcelain #{@ignored_flag}")
    changes = stdout.readlines
    return changes.any?, changes
  end


  def display_current_changes(opts = nil)
    puts ''
    puts "  TO BE COMMITTED ON: #{current_branch}".bold
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


  def display_sync_status
    puts ''
    puts '  SYNC STATUS:'.bold
    stat, count = check_remote_status
    commit_s = (count == 1) ? 'commit' : 'commits'
    case stat
      when :ahead
        puts "  Your #{current_branch.bold + CYAN} branch is ahead of the remote by #{count} #{commit_s}.".cyan
        puts "  (Use 'ezgit pull' to update the remote.)".cyan
      when :behind
        puts "  Your #{current_branch.bold + YELLOW} branch is behind the remote by #{count} #{commit_s}.".yellow
        puts "  (Use 'ezgit pull' to get the new changes.)".yellow
      when :rebase
        puts "  Your #{current_branch} branch has diverged #{count} #{commit_s} from the remote.".red.bold
        puts "  (Use must use git directly to put them back in sync.)".red.bold
      when :no_remote
        puts "  Your #{current_branch.bold + CYAN} branch does not yet exist on the remote.".cyan
        puts "  (Use 'ezgit pull' to update the remote.)".cyan
      when :headless
        puts "  You are in a headless state (not on a branch)".red.bold
        puts "  (Use 'ezgit create <branch>' to create a branch at this commit,".red.bold
        puts "   or use 'ezgit switch <branch>' to switch to a branch.)".red.bold
      else
        puts "  Your #{current_branch.bold + GREEN} branch is in sync with the remote.".green
        puts "  (Use 'ezgit pull' to ensure it stays in sync.)".green
    end
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


  def fetch
    stdin, stdout, stderr = Open3.popen3("git fetch -p #{@dry_run_flag}")
    puts stderr.readlines.join('') + stdout.readlines.join('')
    refresh_branches
  end


  def call_command(command)
    stdin, stdout, stderr = Open3.popen3(command)
    out = stderr.readlines.join('')
    err = stdout.readlines.join('')
    return out, err
  end

end